#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   Run the script directly from GitHub:
#   bash <(curl -fsSL https://raw.githubusercontent.com/PowerShellLibrary/Hacker-Scripts/refs/heads/master/linux/discover-installed-packages.sh)
#
# Discover currently installed Flatpak and APT packages.
#
# Output:
#   .install.yml.updated
#
# The goal is NOT to blindly reproduce the current OS.
# Instead, this produces a useful candidate install.yml plus information
# about packages discovered in shell history.
#
# APT history states:
#   ✓ installed + manual
#   ~ installed + auto
#   ↪ command exists, but history name is not an installed package
#   ✗ not installed
#
# Notes:
#   apt-mark showmanual does NOT mean "packages I personally installed".
#   It means "packages currently marked as manually installed".
#
# Usage:
#   ./sync-installed-packages.sh

OUTPUT_FILE=".install.yml.updated"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

is_installed() {
    local pkg="$1"

    dpkg-query \
        -W \
        -f='${db:Status-Abbrev}\n' \
        "$pkg" 2>/dev/null |
        grep -q '^.i '
}

get_command_provider() {
    local command_name="$1"
    local command_path
    local provider

    command_path="$(command -v -- "$command_name" 2>/dev/null || true)"

    [[ -n "$command_path" ]] || return 1
    [[ -x "$command_path" ]] || return 1

    provider="$(
        dpkg-query -S "$command_path" 2>/dev/null |
            head -n1 |
            cut -d: -f1
    )"

    [[ -n "$provider" ]] || return 1

    printf '%s\n' "$provider"
}

# ---------------------------------------------------------------------------
# Collect Flatpak applications
# ---------------------------------------------------------------------------

echo "Collecting installed Flatpaks..."

FLATPAK_APPS="$(
    flatpak list \
        --app \
        --columns=application \
        2>/dev/null |
        awk 'NF { print $1 }' |
        sort -u
)"

# ---------------------------------------------------------------------------
# Collect APT package state
# ---------------------------------------------------------------------------

echo "Collecting APT package state..."

MANUAL_PKGS="$(
    apt-mark showmanual 2>/dev/null |
        awk 'NF { print $1 }' |
        sort -u
)"

AUTO_PKGS="$(
    apt-mark showauto 2>/dev/null |
        awk 'NF { print $1 }' |
        sort -u
)"

declare -A MANUAL_SET=()
declare -A AUTO_SET=()

while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    MANUAL_SET["$pkg"]=1
done <<< "$MANUAL_PKGS"

while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue
    AUTO_SET["$pkg"]=1
done <<< "$AUTO_PKGS"

# ---------------------------------------------------------------------------
# Extract packages from shell history
# ---------------------------------------------------------------------------
#
# Looks for:
#
#   sudo apt install foo
#   sudo apt install foo bar baz
#   sudo apt install -y foo
#   sudo apt install --no-install-recommends foo bar
#   sudo apt-get install foo
#   apt install foo
#
# This is intentionally conservative rather than trying to implement a
# complete shell parser.
#
# It also understands zsh extended-history prefixes such as:
#
#   : 1750000000:0;sudo apt install foo
#
# History files:
#   ~/.zsh_history
#   ~/.bash_history

echo "Collecting APT install commands from shell history..."

HISTORY_FILES=(
    "$HOME/.zsh_history"
    "$HOME/.bash_history"
)

HISTORY_PKGS="$(
    for history_file in "${HISTORY_FILES[@]}"; do
        [[ -r "$history_file" ]] || continue

        grep -E \
            '(^|[[:space:];])sudo[[:space:]]+(apt|apt-get)[[:space:]]+install([[:space:]]|$)|(^|[[:space:];])(apt|apt-get)[[:space:]]+install([[:space:]]|$)' \
            "$history_file" || true
    done |
    perl -ne '
        # Remove zsh extended-history prefix:
        # : 1750000000:0;
        s/^:\s*\d+:\d+;//;

        # Find apt/apt-get install and everything following it.
        next unless /\b(?:sudo\s+)?apt(?:-get)?\s+install\b(.*)/;

        my $args = $1;

        # Ignore anything after common shell command separators.
        $args =~ s/[;&|].*$//;

        # Split command arguments on whitespace.
        my @tokens = split /\s+/, $args;

        for my $token (@tokens) {
            # Ignore empty tokens.
            next unless length $token;

            # Ignore apt options:
            #   -y
            #   --yes
            #   --no-install-recommends
            #   -o Foo=bar
            next if $token =~ /^-/;

            # Remove simple surrounding quotes.
            $token =~ s/^["'\'']//;
            $token =~ s/["'\'']$//;

            # Basic validation for Debian package names.
            #
            # Allows:
            #   foo
            #   foo-bar
            #   foo_bar
            #   foo.bar
            #   foo+bar
            #   foo:amd64
            next unless $token =~ /^[a-z0-9][a-z0-9.+:_-]*$/;

            print "$token\n";
        }
    ' |
    sort -u
)"

# ---------------------------------------------------------------------------
# Determine state of a package found in shell history
# ---------------------------------------------------------------------------

package_state() {
    local pkg="$1"
    local provider

    # Exact package currently installed.
    if is_installed "$pkg"; then
        if [[ ${MANUAL_SET[$pkg]+_} ]]; then
            printf '%s\n' "manual"
        elif [[ ${AUTO_SET[$pkg]+_} ]]; then
            printf '%s\n' "auto"
        else
            printf '%s\n' "installed"
        fi

        return
    fi

    # The history entry might actually be the name of a command rather than
    # a package currently installed under that exact name.
    #
    # Example:
    #   strings -> /usr/bin/strings -> binutils
    if provider="$(get_command_provider "$pkg")"; then
        printf 'command:%s\n' "$provider"
        return
    fi

    # Nothing matching the exact package name is currently installed.
    printf '%s\n' "missing"
}

# ---------------------------------------------------------------------------
# Build useful candidate APT package list
# ---------------------------------------------------------------------------
#
# We only put currently installed + manually marked packages into
# apt_packages.
#
# Historical packages that are currently auto-installed or absent are kept
# as comments in apt_history_packages for review.

HISTORY_MANUAL_PKGS=()

while IFS= read -r pkg; do
    [[ -n "$pkg" ]] || continue

    state="$(package_state "$pkg")"

    if [[ "$state" == "manual" ]]; then
        HISTORY_MANUAL_PKGS+=("$pkg")
    fi
done <<< "$HISTORY_PKGS"

# ---------------------------------------------------------------------------
# Generate YAML
# ---------------------------------------------------------------------------

echo "Generating $OUTPUT_FILE..."

{
    echo "# Discovered from the current machine."
    echo "# Review this file before merging anything into install.yml."
    echo

    # -----------------------------------------------------------------------
    # Flatpak
    # -----------------------------------------------------------------------

    echo "# Currently installed Flatpak applications"
    echo "flatpak_apps:"

    if [[ -n "$FLATPAK_APPS" ]]; then
        while IFS= read -r app; do
            [[ -n "$app" ]] || continue
            printf '  - %s\n' "$app"
        done <<< "$FLATPAK_APPS"
    else
        echo "  []"
    fi

    echo

    # -----------------------------------------------------------------------
    # APT
    # -----------------------------------------------------------------------

    echo "# Currently installed packages marked as manually installed."
    echo "# NOTE: manual does not necessarily mean explicitly installed by you."
    echo "apt_packages:"

    if [[ -n "$MANUAL_PKGS" ]]; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] || continue
            printf '  - %s\n' "$pkg"
        done <<< "$MANUAL_PKGS"
    else
        echo "  []"
    fi

    echo

    # -----------------------------------------------------------------------
    # Historical package discoveries
    # -----------------------------------------------------------------------

    echo "# Packages discovered in shell history after apt/apt-get install."
    echo "#"
    echo "# ✓ = exact package installed + manually marked"
    echo "# ~ = exact package installed + automatically marked"
    echo "# ↪ = command exists, but that command is provided by another package"
    echo "# ✗ = exact package is not currently installed"
    echo "#"
    echo "# This section is informational and should be reviewed manually."
    echo "apt_history_packages:"

    if [[ -n "$HISTORY_PKGS" ]]; then
        while IFS= read -r pkg; do
            [[ -n "$pkg" ]] || continue

            state="$(package_state "$pkg")"

            case "$state" in
                manual)
                    printf '  # - %s  # ✓ installed, manual\n' "$pkg"
                    ;;

                auto)
                    printf '  # - %s  # ~ installed, auto\n' "$pkg"
                    ;;

                installed)
                    printf '  # - %s  # ~ installed, state unclear\n' "$pkg"
                    ;;

                command:*)
                    provider="${state#command:}"
                    printf '  # - %s  # ↪ command provided by %s\n' \
                        "$pkg" "$provider"
                    ;;

                missing)
                    printf '  # - %s  # ✗ not installed\n' "$pkg"
                    ;;
            esac
        done <<< "$HISTORY_PKGS"
    else
        echo "  []"
    fi

} > "$OUTPUT_FILE"

# ---------------------------------------------------------------------------
# Human-readable summary
# ---------------------------------------------------------------------------

echo
echo "✓ Generated: $OUTPUT_FILE"
echo

echo "=== FLATPAK APPS ==="

if [[ -n "$FLATPAK_APPS" ]]; then
    while IFS= read -r app; do
        [[ -n "$app" ]] || continue
        echo "  $app"
    done <<< "$FLATPAK_APPS"
else
    echo "  (none)"
fi

echo
echo "=== APT PACKAGES MARKED MANUAL ==="

if [[ -n "$MANUAL_PKGS" ]]; then
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] || continue
        echo "  $pkg"
    done <<< "$MANUAL_PKGS"
else
    echo "  (none)"
fi

echo
echo "=== PACKAGES FOUND IN APT SHELL HISTORY ==="

if [[ -n "$HISTORY_PKGS" ]]; then
    while IFS= read -r pkg; do
        [[ -n "$pkg" ]] || continue

        state="$(package_state "$pkg")"

        case "$state" in
            manual)
                echo "  ✓ $pkg (installed, manual)"
                ;;

            auto)
                echo "  ~ $pkg (installed, auto)"
                ;;

            installed)
                echo "  ~ $pkg (installed, state unclear)"
                ;;

            command:*)
                provider="${state#command:}"
                echo "  ↪ $pkg → $provider (command is installed)"
                ;;

            missing)
                echo "  ✗ $pkg (not installed)"
                ;;
        esac
    done <<< "$HISTORY_PKGS"
else
    echo "  (none found)"
fi

echo
echo "Review $OUTPUT_FILE before merging it into install.yml."
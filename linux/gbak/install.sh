#!/usr/bin/env bash
set -Eeuo pipefail

url='https://raw.githubusercontent.com/PowerShellLibrary/Hacker-Scripts/refs/heads/master/linux/gbak/gbak'
destination="$HOME/.local/bin"
mkdir -p "$destination"
temporary=$(mktemp "$destination/.gbak.XXXXXXXX")
trap 'rm -f -- "$temporary"' EXIT

curl -fsSL "$url" -o "$temporary"
test -s "$temporary"
bash -n "$temporary"
chmod 700 "$temporary"
mv -f -- "$temporary" "$destination/gbak"
printf 'Installed gbak: %s/gbak\n' "$destination"

case ":$PATH:" in
  *":$destination:"*) ;;
  *) printf 'Add %s to PATH to run gbak by name.\n' "$destination" ;;
esac
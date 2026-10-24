## Purpose

`gbak` backs up a Git repository's non-ignored changes by creating and pushing a timestamped `work/...` branch to `origin`. After the backup is pushed, it can reset the current branch to its configured `origin` upstream. By default, you must type `RESET` to confirm; pass `-y` to approve automatically.

The reset uses `git reset --hard`, which discards local changes and may overwrite conflicting untracked files. Cancelling leaves the pushed backup branch in place.

## Usage

The repository path defaults to the current directory, which must be the repository root. If no backup comment is provided, `gbak` prompts for it.

```bash
gbak "before refactoring"
gbak -y "before refactoring"
gbak -y "before refactoring" /absolute/path/to/repo
```

`-y` can appear before or after the positional arguments. All backup and repository safety checks still apply.

## Deploy `gbak`

For a one-line install or update, run this on the target machine:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/PowerShellLibrary/Hacker-Scripts/refs/heads/master/linux/gbak/install.sh)
```

The installer downloads `gbak` from `master`, checks Bash syntax, and installs it as `~/.local/bin/gbak` with permissions `700`. Failed downloads leave the installed copy untouched. It does not run a backup or change your shell configuration. Only run downloaded code from a source you trust.

From the repository root, install it locally as `gbak`:

```bash
install -Dm700 linux/gbak/gbak "$HOME/.local/bin/gbak"
```

To deploy it to another machine over SSH, run this from the repository root:

```bash
ssh alan@cloud-dev 'bash -s' < linux/gbak/install.sh
```

Replace `alan@cloud-dev` with the SSH destination. All install methods require `~/.local/bin` to be on `PATH` to run `gbak` by name.
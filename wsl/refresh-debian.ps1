# Refresh Debian WSL distribution by unregistering and reinstalling it.
# This is useful when the distribution is corrupted or when you want to reset it.

wsl -l -v
wsl --unregister Debian
wsl --install -d Debian
# Source: https://learn.microsoft.com/en-us/powershell/scripting/install/install-debian?view=powershell-7.5

# Update the list of packages
sudo apt-get update

# Install pre-requisite packages.
sudo apt-get install -y wget

# Download the PowerShell package file
wget https://github.com/PowerShell/PowerShell/releases/download/v7.5.0/powershell_7.5.0-1.deb_amd64.deb

# Install the PowerShell package
sudo dpkg -i powershell_7.5.0-1.deb_amd64.deb

# Resolve missing dependencies and finish the install (if necessary)
sudo apt-get install -f

# Delete the downloaded package file
rm powershell_7.5.0-1.deb_amd64.deb

# Start PowerShell
pwsh
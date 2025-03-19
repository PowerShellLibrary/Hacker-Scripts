# Prerequisites - you need to get SSH key supported by your git hosting service.
# deploy it into: c:\id_rsa

# generate SSH key
ssh-keygen -t rsa -b 4096 -C "key-comment" # 4096 RSA key (SHA256)
ssh-keygen -t ed25519 -C "key-comment"

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# install dependencies
choco install git -y

# deploy SSH key into keys store
$userName = [Environment]::UserName
Write-Host "Username: $userName" -ForegroundColor Green
Get-Item c:\id_rsa | Copy-Item -Destination "C:\Users\$userName\.ssh\id_rsa"

# enable ssh service
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
Start-Service ssh-agent

# register ssh key
ssh-add "C:\Users\$userName\.ssh\id_rsa"

# register known_hosts
ssh-keyscan bitbucket.org >> "C:\Users\$userName\.ssh\known_hosts"
ssh-keyscan github.com >> "C:\Users\$userName\.ssh\known_hosts"
ssh-keyscan vs-ssh.visualstudio.com >> "C:\Users\$userName\.ssh\known_hosts"

# test connection to git repositories
ssh -T ssh://alan-null@vs-ssh.visualstudio.com
ssh -T git@bitbucket.org
ssh -T git@github.com
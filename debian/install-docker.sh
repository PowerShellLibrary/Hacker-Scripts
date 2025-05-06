# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
ARCH=$(dpkg --print-architecture)
CODENAME=$(source /etc/os-release && echo "$VERSION_CODENAME")
REPO_URL="deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $CODENAME stable"
echo "$REPO_URL" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

# Install latest version
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
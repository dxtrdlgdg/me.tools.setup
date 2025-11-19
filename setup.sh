#!/bin/bash
set -e

echo "===================================================="
echo "   Workstation Initial Setup (Ubuntu)"
echo "===================================================="
sleep 1

echo "=== Updating system ==="
sudo apt update -y
sudo apt upgrade -y

echo "=== Installing base packages ==="
sudo apt install -y git curl wget gnupg lsb-release ca-certificates software-properties-common

############################################################
# INSTALL DOCKER (LATEST, OFFICIAL)
############################################################
echo "=== Installing Docker Engine ==="

# Remove old docker versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Setup Docker repository
sudo install -m 0755 -d /etc/apt/keyrings || true
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (rootless docker)
sudo groupadd docker || true
sudo usermod -aG docker $USER

echo "Docker installation complete."

############################################################
# INSTALL AWS CLI
############################################################
echo "=== Installing AWS CLI ==="
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

############################################################
# INSTALL GCP CLI
############################################################
echo "=== Installing GCP CLI ==="
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt update -y
sudo apt install -y google-cloud-cli

############################################################
# INSTALL k3d
############################################################
echo "=== Installing k3d ==="
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

############################################################
# INSTALL OPENJDK 11
############################################################
echo "=== Installing OpenJDK 11 ==="
sudo apt install -y openjdk-11-jdk

############################################################
# INSTALL NVM + NODE 18
############################################################
echo "=== Installing NVM & Node v18 ==="
export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
fi

# Load nvm
source "$HOME/.nvm/nvm.sh"

nvm install 18
nvm use 18

############################################################
# INSTALL KEYSTORE EXPLORER
############################################################
echo "=== Installing Keystore Explorer (KSE 5.6.0) ==="
wget https://github.com/kaikramer/keystore-explorer/releases/download/v5.6.0/kse_5.6.0_all.deb -O kse.deb
sudo apt install -y ./kse.deb
rm kse.deb

############################################################
# INSTALL FLATPAK + APPS
############################################################
echo "=== Installing Flatpak ==="
sudo apt install -y flatpak

echo "=== Adding Flathub repository ==="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "=== Installing GUI Applications ==="
flatpak install -y flathub com.slack.Slack
flatpak install -y flathub com.visualstudio.code
flatpak install -y flathub com.viber.Viber
flatpak install -y flathub org.localsend.localsend_app
flatpak install -y flathub io.dbeaver.DBeaverCommunity

############################################################
echo "===================================================="
echo " Setup COMPLETE! Please log out and log back in "
echo "   for Docker group changes to apply. "
echo "===================================================="

#!/bin/bash

# Exit on any error
set -e

# Update system
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker's official repository
echo "Adding Docker's repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package list again
echo "Updating package list..."
sudo apt update

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt install -y docker-ce

# Verify Docker installation
echo "Verifying Docker installation..."
sudo systemctl status docker || true
docker --version

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
docker-compose --version

# Manage Docker as a non-root user (optional)
echo "Setting up Docker to be run as a non-root user..."
sudo usermod -aG docker $USER
echo "You need to log out and log back in for the group changes to take effect."
echo "Script completed successfully."

#!/bin/bash

# Exit on any error
set -e

# Backup and replace source list. AWS default data transfer within region 1GB only.
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
sudo sed -i 's/ap-southeast-1.ec2.//g' /etc/apt/sources.list.d/ubuntu.sources

# Update system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker's official repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package list again
sudo apt update

# Install Docker Engine
sudo apt install -y docker-ce

# Verify Docker installation
sudo systemctl status docker || true
docker --version

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Manage Docker as a non-root user (optional)
sudo usermod -aG docker ubuntu

# Create a directory for Docker Compose files
mkdir -p /home/ubuntu/gitea

# Create a Docker Compose file for Gitea and PostgreSQL
cat <<EOL > /home/ubuntu/gitea/docker-compose.yml
version: '3'
services:
  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=gitea
      - POSTGRES_USER=gitea
      - POSTGRES_PASSWORD=gitea
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
    networks:
      - gitea_network

  gitea:
    image: gitea/gitea:latest
    ports:
      - "80:3000"
      - "2222:22"
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - GITEA__Database_TYPE=postgres
      - GITEA__Database_HOST=db:5432
      - GITEA__Database_NAME=gitea
      - GITEA__Database_USER=gitea
      - GITEA__Database_PASSWD=gitea
    volumes:
      - ./gitea_data:/data
    depends_on:
      - db
    networks:
      - gitea_network

networks:
  gitea_network:
EOL

# Run Docker Compose to start Gitea and PostgreSQL
cd /home/ubuntu/gitea
docker-compose up -d
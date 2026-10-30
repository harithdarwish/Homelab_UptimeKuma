#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Uptime Kuma Installation & Deployment ==="

# 1. Update system and install prerequisites
echo "-> Updating system and installing prerequisites..."
apt update && apt install -y ca-certificates curl gnupg

# 2. Add Docker's official GPG key and APT repository for Debian
echo "-> Setting up Docker repository..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install Docker Engine and Docker Compose plugin
echo "-> Installing Docker Engine and Docker Compose..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Ensure external Docker volume exists
echo "-> Verifying external volume..."
docker volume inspect uptime-kuma_uptime-kuma-data >/dev/null 2>&1 || \
  (echo "-> Creating named volume: uptime-kuma_uptime-kuma-data" && docker volume create uptime-kuma_uptime-kuma-data)

# 5. Launch Uptime Kuma stack
echo "-> Starting Uptime Kuma container..."
docker compose up -d

echo "=== Installation Complete! ==="
echo "Uptime Kuma is running at: http://$(hostname -I | awk '{print $1}'):3001"

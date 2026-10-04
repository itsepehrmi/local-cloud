#!/bin/bash
#
# setup-server.sh - Prepare the server for application deployment
# Run this INSIDE the server (container), not on the host.
#

set -euo pipeline

APP_NAME="myapp"
APP_USER="deploy"
APP_DIR="/opt/${APP_NAME}"
LOG_DIR="/var/log/${APP_NAME}"

echo "======================================="
echo " Setting up server for: ${APP_NAME}"
echo "======================================="

# --- 1. Update package list ---
echo "[1/5] Updating package list..."
sudo apt-get update -qq

# --- 2. Install required packages ---
echo "[2/5] Installing required packages..."
sudo apt-get install -y -qq \
    python3 \
    python3-pip \
    python3-venv \
    nginx \
    curl

# --- 3. Create application directory ---
echo "[3/5] Creating ${APP_DIR}..."
sudo mkdir -p "${APP_DIR}"
sudo chown -R "${APP_USER}:${APP_USER}" "${APP_DIR}"

# --- 4. Create log directory ---
echo "[4/5] Creating ${LOG_DIR}.."
sudo mkdir -p "${LOG_DIR}..."
sudo chown -R "${APP_USER}:${APP_USER}" "${LOG_DIR}"

# --- 5. Verify installation ---
echo "[5/5] Verifying installation..."
python3 --version
pip3 --version
nginx -v

echo ""
echo "======================================"
echo " Server setup complete!"
echo "======================================"
echo "App directory: ${APP_DIR}"
echo "Log directory: ${LOG_DIR}"
echo ""
echo "Next step: deploy the application"

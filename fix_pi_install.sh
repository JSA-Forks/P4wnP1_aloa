#!/bin/bash

# P4wnP1 A.L.O.A. Modern Install Script
# Fixes issues with obsolete dependencies (Python 2, Go 1.10) on modern RPi OS.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "=========================================="
echo "    P4wnP1 Modern Installer / Fixer       "
echo "=========================================="

# 0. Check Environment & Download Repo
echo "[*] Checking environment..."
if [ ! -f "go.mod" ]; then
    echo "    Script is running standalone."
    if [ -d "P4wnP1_aloa" ]; then
        echo "    Found existing P4wnP1_aloa folder. Configuring to ignore it and pull fresh if needed, or use it."
        cd P4wnP1_aloa
    else
        echo "    P4wnP1 repository not found. Cloning from GitHub..."
        sudo apt-get update && sudo apt-get install -y git
        git clone https://github.com/mame82/P4wnP1_aloa.git P4wnP1_aloa
        cd P4wnP1_aloa
    fi
fi
echo "    Working directory: $(pwd)"

# 1. Install System Dependencies
echo "[*] Installing system dependencies..."
apt-get install -y \
    git screen hostapd autossh \
    bluez bluez-tools bridge-utils \
    policykit-1 genisoimage iodine haveged \
    tcpdump dnsmasq \
    python3 python3-pip python3-dev \
    golang

# 2. Python Dependencies (Fixing pycrypto issue)
echo "[*] Installing Python dependencies..."
# Modern OS (Bookworm+) requires --break-system-packages or a venv. 
# For P4wnP1 which takes over the device, we'll try global install.
PIP_ARGS=""
if pip3 install --help | grep -q "break-system-packages"; then
    PIP_ARGS="--break-system-packages"
fi

# PyCrypto is dead. Use PyCryptodome as a drop-in replacement.
pip3 install $PIP_ARGS pycryptodome pydispatcher

# 3. Setup Go Environment
echo "[*] Setting up Go environment..."
# Assuming Go is installed via apt (likely 1.19+ on modern RPiOS)
export GOPATH=/root/go
export GOCACHE=/root/.cache/go-build
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

mkdir -p $GOPATH

# Install GopherJS (needed for web client)
echo "[*] Installing GopherJS..."
go install github.com/gopherjs/gopherjs@v1.18.0-beta2

# 4. Compile Binaries
echo "[*] Compiling P4wnP1..."

# We need to run go install/build from the repo root
REPO_DIR=$(pwd)

# Compile Service and CLI
cd "$REPO_DIR" || exit
go install ./cmd/...
# Copy binaries to build/ for consistency with original scripts
mkdir -p build
cp "$GOPATH/bin/P4wnP1_service" build/
cp "$GOPATH/bin/P4wnP1_cli" build/

# Compile Web Client
echo "[*] Compiling Web Client..."
# Ensure gopherjs is in path
export PATH=$PATH:$(go env GOPATH)/bin
gopherjs get github.com/mame82/P4wnP1_aloa/web_client/...
gopherjs build -m -o build/webapp.js web_client/*.go

# 5. Install Files
echo "[*] Installing files to /usr/local..."
cp build/P4wnP1_service /usr/local/bin/
cp build/P4wnP1_cli /usr/local/bin/

mkdir -p /usr/local/P4wnP1
cp -R dist/keymaps /usr/local/P4wnP1/
cp -R dist/scripts /usr/local/P4wnP1/
cp -R dist/HIDScripts /usr/local/P4wnP1/
cp -R dist/www /usr/local/P4wnP1/
cp -R dist/db /usr/local/P4wnP1/
cp -R dist/helper /usr/local/P4wnP1/
cp -R dist/ums /usr/local/P4wnP1/
cp -R dist/legacy /usr/local/P4wnP1/

# Copy compiled webapp
cp build/webapp.js /usr/local/P4wnP1/www
cp build/webapp.js.map /usr/local/P4wnP1/www

# 6. Service Installation
echo "[*] Configuring Systemd..."
cp dist/P4wnP1.service /etc/systemd/system/P4wnP1.service
systemctl daemon-reload

# Disable conflicting services
systemctl stop dnsmasq
systemctl disable dnsmasq
# Note: P4wnP1 manages networking, but disabling 'networking' service 
# on modern RPiOS (managed by NetworkManager) might be aggressive.
# We will leave NetworkManager alone for now, user might need to adjust.

echo "[*] Enabling P4wnP1 Service..."
systemctl enable P4wnP1.service

echo "=========================================="
echo "    Installation Complete!                "
echo "    Please reboot your Pi.                "
echo "=========================================="

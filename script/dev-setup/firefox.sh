#!/bin/bash

# Exit if any command fails
set -e

# Variables
FIREFOX_URL="https://download.mozilla.org/?product=firefox-latest&os=linux64-aarch64&lang=en-US"
TMP_DIR="/tmp/firefox-install"
INSTALL_DIR="/opt/firefox"

# Create temporary directory
mkdir -p $TMP_DIR
cd $TMP_DIR

# Download latest Firefox ARM64
echo "Downloading latest Firefox for ARM64..."
wget -O firefox.tar.bz2 "$FIREFOX_URL"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing old Firefox installation..."
    sudo rm -rf "$INSTALL_DIR"
fi

# Extract to /opt
echo "Extracting Firefox..."
sudo tar -xjf firefox.tar.bz2 -C /opt

# Create symlink
echo "Creating symlink..."
sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox

# Cleanup
cd ~
rm -rf $TMP_DIR

echo "Firefox installed successfully! Run 'firefox' to start."

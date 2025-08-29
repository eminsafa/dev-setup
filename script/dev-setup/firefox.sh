#!/bin/bash

set -e

# Variables
FIREFOX_URL="https://ftp.mozilla.org/pub/firefox/releases/latest/linux-aarch64/en-US/firefox-*.tar.bz2"
TMP_DIR="/tmp/firefox-install"
INSTALL_DIR="/opt/firefox"

mkdir -p $TMP_DIR
cd $TMP_DIR

echo "Downloading Firefox ARM64..."
wget -O firefox.tar.bz2 "$FIREFOX_URL"

echo "Removing old installation if exists..."
sudo rm -rf "$INSTALL_DIR"

echo "Extracting Firefox..."
sudo tar -xjf firefox.tar.bz2 -C /opt

echo "Creating symlink..."
sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox

cd ~
rm -rf $TMP_DIR

echo "Firefox installed successfully! Run 'firefox' to start."

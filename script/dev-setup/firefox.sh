#!/bin/bash
set -e

# Function to detect Debian version
get_debian_version() {
    . /etc/os-release
    echo "$VERSION_CODENAME"
}

# Create keyrings directory if it doesn't exist
sudo install -d -m 0755 /etc/apt/keyrings

# Install wget if not present
if ! command -v wget &>/dev/null; then
    echo "wget not found, installing..."
    sudo apt-get update
    sudo apt-get install -y wget
fi

# Download and save Mozilla signing key
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

# Verify the fingerprint
EXPECTED_FINGERPRINT="35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3"
ACTUAL_FINGERPRINT=$(gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc \
    | awk '/pub/{getline; gsub(/^ +| +$/,""); print $0}')

if [[ "$ACTUAL_FINGERPRINT" == "$EXPECTED_FINGERPRINT" ]]; then
    echo "The key fingerprint matches ($ACTUAL_FINGERPRINT)."
else
    echo "Verification failed: the fingerprint ($ACTUAL_FINGERPRINT) does not match the expected one."
    exit 1
fi

# Detect Debian version and add appropriate repository
DEBIAN_VERSION=$(get_debian_version)

if [[ "$DEBIAN_VERSION" == "bookworm" || "$DEBIAN_VERSION" == "bullseye" || "$DEBIAN_VERSION" == "buster" ]]; then
    echo "Adding Mozilla repository for Debian $DEBIAN_VERSION (Bookworm or older)..."
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
        | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
else
    echo "Adding Mozilla repository for Debian $DEBIAN_VERSION (Trixie or newer)..."
    sudo tee /etc/apt/sources.list.d/mozilla.sources > /dev/null <<EOF
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
fi

# Configure APT pinning for Mozilla packages
sudo tee /etc/apt/preferences.d/mozilla > /dev/null <<EOF
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

# Update package list and install Firefox
sudo apt-get update
sudo apt-get install -y firefox

echo "Mozilla Firefox installation completed successfully."

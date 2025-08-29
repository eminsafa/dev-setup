#!/bin/bash
set -e

echo "Updating package list..."
sudo apt update && sudo apt upgrade -y

# --- Install Terminator ---
echo "Installing Terminator..."
sudo apt install -y terminator

# --- Install VS Code ---
echo "Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo apt update
sudo apt install -y code

# --- Install PyCharm (Community Edition) ---
echo "Installing PyCharm Community Edition..."
sudo snap install pycharm-community --classic

# (Optional: Professional version)
# sudo snap install pycharm-professional --classic

# --- Setup SSH Keys for GitHub ---
echo "Setting up SSH keys for GitHub..."

mkdir -p ~/.ssh
chmod 700 ~/.ssh

private_key_encrypted=$(cat <<EOF
U2FsdGVkX1+4TZqt9vINWPjNPtbdGIjvFKExPbHpFMqY1BnZEzUyvEGe3+yXx/nb
ykfD9KNXAmFE0IYOV5i+OCfm8fDD8K12nATxYtpMfnVMREEaf4janaSXdxVVR7XV
caSQu6EEz0PwIoX5RgHRlj9JK1EnGPfQo4mdwYUfY+zSngIU4KRBxPBeMRXpU6SY
rsiBU0/cBadTbQtRzImfIeV8Fi0dJYH2Jko/0ZAJwpdAfkLeypsg8yFqYEajPkry
GrUDPiX+8JDQdPsodzcCGX26ykqPSXCbCpZK1L7fVTBtOnjeUL4fnLLBzIa08Dx9
P6Kgc7AUBN7ms6T9AMkze2MRJeVWrElBHccBiYC/4T+b2Nxh/Y6+QJTOOl58A6qz
IzvdcDKuBLibDacyik8BFWBKiWUdeivkk7JfAmh27Ew9JKrq6I7+jFWkWRZq2zWx
+cLZTqXJtWdG+z0UCIy9Ydf+wrpaNhHRpIP8emJE6NAlOO2igOqzEkEZ2NJjyw0q
69JDY1gGyygjKvMwzT5Vej1tcbQRjA/QNhKWl4FwQYtkKFpwskp/pZKMNWfHwJps
EOF
)
public_key_encrypted=$(cat <<EOF
U2FsdGVkX18NX3bfG6zHO+pt8/7sWg9F9RatmAuqrBHi+n8t1vLXKDinhcoxaWlD
qKeJghtrE5/jzWsmf3reK4ZyYPgaKd7xCNbkgyhU4aQ+d9P8D286LnZhN6CP1yrw
+BlxkhDQRdb4M2mJiDCRrKH5+q+bQrvSMdDPI5Z2oTQ=
EOF
)

private_key=$(echo "$encrypted_private_key" | openssl enc -aes-256-cbc -d -a -pbkdf2 -iter 500000 -k "$passphrase" 2>/dev/null)
echo "$private_key" > ~/.ssh/est_ssh_key

public_key=$(echo "$encrypted_public_key" | openssl enc -aes-256-cbc -d -a -pbkdf2 -iter 500000 -k "$passphrase" 2>/dev/null)
echo "$public_key" > ~/.ssh/est_ssh_key.pub

chmod 600 ~/.ssh/est_ssh_key
chmod 644 ~/.ssh/est_ssh_key.pub

# --- SSH Config for GitHub ---
cat > ~/.ssh/config <<'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/est_ssh_key
  AddKeysToAgent yes
  IdentitiesOnly yes
EOF

chmod 600 ~/.ssh/config

# --- Test GitHub SSH connection ---
echo "Testing GitHub SSH connection..."
ssh -T git@github.com || true

echo "All done! Installed: Terminator, VS Code, PyCharm, and GitHub SSH setup."

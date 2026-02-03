#!/bin/bash

# 1. Update package list and install WireGuard + resolvconf (needed for DNS handling)
echo "Installing WireGuard..."
sudo apt update
sudo apt install -y wireguard resolvconf

# 2. Create the configuration file directly in /etc/wireguard/
# We use 'cat' with a Heredoc (<<EOF) wrapped in sudo to write to the protected directory.
echo "Creating wg0.conf..."
sudo bash -c 'cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
Address = 10.14.0.2/16
PrivateKey = IKaW/3h9QYcJ4pckp9i21++CPD6ors6LrffqekxCw1A=
DNS = 162.252.172.57, 149.154.159.92

[Peer]
PublicKey = fJDA+OA6jzQxfRcoHfC27xz7m3C8/590fRjpntzSpGo=
AllowedIPs = 0.0.0.0/0
Endpoint = de-fra.prod.surfshark.com:51820
EOF'

# 3. Set the required permissions (read/write for root only)
echo "Setting permissions..."
sudo chmod 600 /etc/wireguard/wg0.conf

# 4. Start the WireGuard interface
echo "Starting WireGuard..."
sudo wg-quick up wg0

# Optional: Check status
echo "Done! Status:"
sudo wg show

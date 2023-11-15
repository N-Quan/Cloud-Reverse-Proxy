# Install WireGuard
sudo apt update -y
sudo apt install wireguard -y

# Generate keys
(umask 077 && printf "[Interface]\nPrivateKey= " | sudo tee /etc/wireguard/wg0.conf > /dev/null) 
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# Get VPS public IP
echo "Enter the public IP of your VPS:" 
read -r vps_public_ip

# Get VPS public key
echo "Enter the public key from your VPS:" 
read -r vps_pubkey

# Wireguard Config
echo "Address = 192.168.4.2 
[Peer] 
PublicKey = $vps_pubkey 
AllowedIPs = 192.168.4.1/32 
Endpoint = $vps_public_ip:55107 
PersistentKeepalive = 25 " | sudo tee -a /etc/wireguard/wg0.conf >/dev/null

# Start Wireguard
sudo systemctl start wg-quick@wg0 
sudo systemctl enable wg-quick@wg0

echo "Wireguard Successfully Configured!"
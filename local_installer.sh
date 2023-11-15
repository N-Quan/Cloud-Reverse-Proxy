############################################## WIREGUARD ##############################################
# Install WireGuard
sudo apt update -y
sudo apt install wireguard -y

# Generate keys
(umask 077 && printf "[Interface]\nPrivateKey= " | sudo tee /etc/wireguard/wg0.conf > /dev/null) 
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# Get VPS public IP
echo "Enter the public IP of your VPS/ Cloud Server:" 
read -r vps_public_ip

# Get VPS public key
echo "Enter the public key from your VPS/ Cloud Server:" 
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

######################################### NGINX PROXY MANAGER #########################################
# Install Docker
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
# Install Portainer
sudo docker volume create portainer_data
sudo docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Run Nginx Proxy Manager Container
docker run -d \
  --name nginx-proxy-manager \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -p 81:81 \
  -v /home/ubuntu/server_configs/nginxproxymanager/data:/data \
  -v /home/ubuntu/server_configs/nginxproxymanager/letsencrypt:/etc/letsencrypt \
  jc21/nginx-proxy-manager:latest

clear 

echo "Local Machine public key is:"
cat /etc/wireguard/publickey
echo "Portainer is running on $(hostname -I | awk '{print $1}'):9443"
echo "Setup Nginx Proxy Manager at $(hostname -I | awk '{print $1}'):81 to start hosting your services to the web!"
######################################################################################################
########################################### CLOUD SERVER #############################################
######################################################################################################
# Install WireGuard
sudo apt update -y
sudo apt install wireguard -y

# Generate keys
(umask 077 && printf "[Interface]\nPrivateKey= " | sudo tee /etc/wireguard/wg0.conf > /dev/null) 
wg genkey | sudo tee -a /etc/wireguard/wg0.conf | wg pubkey | sudo tee /etc/wireguard/publickey

# Get home server public key
echo "Enter the public key from your home server/ local machine:" 
read -r home_server_pubkey

# Wireguard Config
echo "ListenPort = 55107 
Address = 192.168.4.1 

PostUp = iptables -P FORWARD DROP
PostUp = iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
PostUp = iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 443 -m conntrack --ctstate NEW -j ACCEPT
PostUp = iptables -A FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.2
PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 192.168.4.2
PostUp = iptables -t nat -A POSTROUTING -o wg0 -p tcp --dport 80 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1
PostUp = iptables -t nat -A POSTROUTING -o wg0 -p tcp --dport 443 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1

PostDown = iptables -P FORWARD ACCEPT
PostDown = iptables -D FORWARD -i eth0 -o wg0 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
PostDown = iptables -D FORWARD -i eth0 -o wg0 -p tcp --syn --dport 443 -m conntrack --ctstate NEW -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.2
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 192.168.4.2
PostDown = iptables -t nat -D POSTROUTING -o wg0 -p tcp --dport 80 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1
PostDown = iptables -t nat -D POSTROUTING -o wg0 -p tcp --dport 443 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1

[Peer] 
PublicKey = $home_server_pubkey
AllowedIPs = 192.168.4.2/32 
" | sudo tee -a /etc/wireguard/wg0.conf >/dev/null

# Allow IPv4 forwarding
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.conf >/dev/null

# Apply changes
sudo sysctl -p 
sudo sysctl --system

# Start Wireguard
sudo systemctl start wg-quick@wg0 
sudo systemctl enable wg-quick@wg0

clear
echo "Cloud Server public key is:"
cat /etc/wireguard/publickey
echo "Wireguard Successfully Configured!"


#######################################################################################################
########################################### LOCAL MACHINE #############################################
#######################################################################################################

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
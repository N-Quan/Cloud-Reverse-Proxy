# Cloud Reverse Proxy
Cloud Reverse Proxy enables applications to be exposed to the internet without the need for public IP addresses or opening ports on a firewall.

This project configures a Reverse Proxy-over-VPN (RPoVPN) and is ideal for those:
- Self-hosting behind double-NAT or via an ISP that does CGNAT (Starlink, Mobile Internet).
- Unable to port forward on their local network due to insufficient access.
- With a dynamically allocated IP that may change frequently.

# Getting Started
## Prerequisites
- Create domain name with record pointing to the Cloud Server's public ip.
- A cloud server running Ubuntu (AWS, Digital Ocean, etc..) with the following requirements:
    - Open TCP ports 80/443 (http(s)) and UDP port 55107
- A local machine in your home network.

## Steps
### 1. Cloud Installer
Run this script on the Cloud Server and follow prompts
```
curl -s https://raw.githubusercontent.com/N-Quan/Self-Hosted-Gateway/main/cloud_installer.sh | sudo bash
```

### 2. Local Installer
Run this script on your Local Machine and follow prompts.
```
curl -s https://raw.githubusercontent.com/N-Quan/Self-Hosted-Gateway/main/local_installer.shh | sudo bash
```

### 3. Setup Nginx Proxy Manager (NPM)
Follow the URL provided by the Local Installer to configure NPM.

# Network Topology
## Cloud Server
Your domain sends http(s) traffic to the Cloud Server running WireGuard. The http(s) traffic gets forwarded to the Local Machine in your home network via the WireGuard tunnel.

## Local Machine running reverse proxy
Receives tunneled http(s) traffic which hits Nginx Proxy Manager (NPM).
NPM can point to any service running in the home network. Hosted services can be running on the same or different machine.
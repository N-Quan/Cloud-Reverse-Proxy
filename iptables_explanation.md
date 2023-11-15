# IP Tables Explanation

## By default, drop traffic
```
sudo iptables -P FORWARD DROP
```

## Allow traffic on specified ports
- These rules allow new incoming TCP connections on ports 80 (HTTP) and 443 (HTTPS) from interface eth0 to wg0. 
- The --syn flag ensures that only SYN packets (which initiate TCP connections) are considered, and --ctstate NEW indicates that only new connections are allowed.
```
sudo iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wg0 -p tcp --syn --dport 443 -m conntrack --ctstate NEW -j ACCEPT
```

## Allow traffic between wg0 and eth0 if connections are already established
```
sudo iptables -A FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -i wg0 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
```

## Forward traffic from eth0 to wg0 on specified ports
- These rules perform Destination Network Address Translation (DNAT). Traffic on ports 80 and 443 arriving at eth0 is forwarded to the internal IP address 192.168.4.2. 
- It's used to redirect incoming connections to a specific internal machine or service. 
```
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.4.2
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to-destination 192.168.4.2
```

## Forward traffic back to eth0 from wg0 on specified ports
- These rules perform Source Network Address Translation (SNAT). Outgoing traffic from wg0 to 192.168.4.2 on ports 80 and 443 will have its source address changed to 192.168.4.1. 
- It's useful for ensuring that responses from internal services appear to come from the VPS's IP address.
```
sudo iptables -t nat -A POSTROUTING -o wg0 -p tcp --dport 80 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1
sudo iptables -t nat -A POSTROUTING -o wg0 -p tcp --dport 443 -d 192.168.4.2 -j SNAT --to-source 192.168.4.1
```
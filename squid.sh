#!/bin/bash
# For CentOs8
# https://computingforgeeks.com/install-and-configure-squid-proxy-on-centos-rhel-linux/
sudo dnf -y update
sudo dnf install squid -y
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf_orig
sudo firewall-cmd --add-service=squid --permanent
sudo firewall-cmd --reload
sudo tee /etc/profile.d/proxyserver.sh <<EOF
MY_PROXY_URL="192.168.1.6:3128"  ## If your server has a domain name, you can replace the IP with it. 
HTTP_PROXY=$MY_PROXY_URL
HTTPS_PROXY=$MY_PROXY_URL
FTP_PROXY=$MY_PROXY_URL
http_proxy=$MY_PROXY_URL
https_proxy=$MY_PROXY_URL
ftp_proxy=$MY_PROXY_URL
EOF
source /etc/profile.d/proxyserver.sh
sudo systemctl start squid

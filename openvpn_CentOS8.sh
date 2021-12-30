#!/bin/bash
# For CentOs8
# https://www.dmosk.ru/miniinstruktions.php?mini=openvpn-centos8
sudo dnf -y update
sudo setenforce 0
sudo firewall-cmd --permanent --add-port=1194/udp
sudo firewall-cmd --reload
sudo dnf install -y epel-release
sudo dnf install -y openvpn easy-rsa
cd /usr/share/easy-rsa/3
sudo tee vars <<EOF
export KEY_COUNTRY="GR"
export KEY_PROVINCE="Berlin"
export KEY_CITY="Berlin"
export KEY_ORG="Berlin COMPANY"
export KEY_EMAIL="master@berlin.com"
export KEY_CN="BERLIN"
export KEY_OU="BERLIN"
export KEY_NAME="openvpn-server.berlin.com"
export KEY_ALTNAMES="openvpn-server"
EOF
sudo chmod +x vars
sudo ./vars
sudo ./easyrsa init-pki
sudo ./easyrsa build-ca

sudo ./easyrsa gen-dh
sudo ./easyrsa gen-req vpn-server nopass
sudo ./easyrsa sign-req server vpn-server
sudo openvpn --genkey --secret pki/ta.key
sudo mkdir -p /etc/openvpn/server/keys
su root
sudo cd pki
sudo cp ca.crt issued/vpn-server.crt private/vpn-server.key dh.pem ta.key /etc/openvpn/server/keys/
exit
sudo tee /etc/openvpn/server/server.conf <<EOF
local 192.168.10.50
port 1194
proto udp
dev tun
ca keys/ca.crt
cert keys/vpn-server.crt
key keys/vpn-server.key
dh keys/dh.pem
tls-auth keys/ta.key 0
server 172.16.11.0 255.255.255.0
ifconfig-pool-persist ipp.txt
keepalive 10 120
max-clients 32
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 0
mute 20
daemon
mode server
tls-server
comp-lzo no
EOF
sudo mkdir /var/log/openvpn
sudo systemctl enable openvpn-server@server
sudo systemctl start openvpn-server@server
sudo systemctl status openvpn-server@server
#############Client-cert-genr#########################
cd /usr/share/easy-rsa/3
sudo ./vars
sudo ./easyrsa gen-req client1 nopass
sudo ./easyrsa sign-req client client1
sudo mkdir /tmp/keys
su root
cd /usr/share/easy-rsa/3
cp pki/issued/client1.crt pki/private/client1.key pki/dh.pem pki/ca.crt pki/ta.key /tmp/keys
exit
sudo chmod -R a+r /tmp/keys
#####################################
##############Client-settings-for-windows##################
# C:\Program Files\OpenVPN\config.
# Копируем в нее файлы ca.crt, client1.crt, client1.key, dh.pem, ta.key из каталога /tmp/keys
# Сохраняем файл с именем config.ovpn в папке C:\Program Files\OpenVPN\config.
# client
# resolv-retry infinite
# nobind
# remote 192.168.10.50 1194
# proto udp
# dev tun
# comp-lzo no
# ca ca.crt
# cert client1.crt
# key client1.key
# dh dh.pem
# tls-client
# tls-auth ta.key 1
# float
# keepalive 10 120
# persist-key
# persist-tun
# verb 0
#####################################

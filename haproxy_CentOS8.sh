#!/bin/bash
sudo dnf -y update
sudo dnf install haproxy -y
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-bak
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --zone=public --add-port=5000/tcp
sudo firewall-cmd --reload
sudo systemctl start haproxy
sudo systemctl enable haproxy

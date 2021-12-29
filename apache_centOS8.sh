#!/bin/bash
sudo dnf -y update
sudo dnf -y install httpd
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
sudo setsebool -P httpd_unified 1
sudo systemctl start httpd


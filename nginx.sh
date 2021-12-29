#!/bin/bash
# For Ubuntu 20.04
sudo wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo tee /etc/apt <<EOF
deb http://nginx.org/packages/ubuntu focal nginx
deb-src http://nginx.org/packages/ubuntu focal nginx
EOF
sudo apt-get -y update
sudo apt -y install nginx
sudo systemctl start nginx.service

#sudo nano /etc/ssh/sshd_config
#port to 8022
sudo ufw allow 8022/tcp
sudo systemctl restart ssh



##add nginx Germany sudo nano /etc/nginx/sites-enabled/default
        # location / {
        #         proxy_pass http://35.180.131.244;
        #         proxy_set_header Host $host;
        #         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #         proxy_set_header X-Real-IP $remote_addr;
        #         # First attempt to serve request as file, then
        #         # as directory, then fall back to displaying a 404.
        #         try_files $uri $uri/ =404;
        # }



#sudo firewall-cmd --permanent --zone=public --add-port=8022/tcp
#sudo firewall-cmd --reload
#sudo systemctl restart sshd


## https://webguard.pro/web-services/nginx/generacziya-ssl-sertifikata-dlya-nginx-openssl.html 
## Poland
# mkdir /etc/nginx/ssl
# openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
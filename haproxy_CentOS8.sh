#!/bin/bash
sudo dnf -y update
sudo dnf install haproxy -y
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-bak
sudo rm /etc/haproxy/haproxy.cfg
sudo tee /etc/haproxy/haproxy.cfg <<EOF
global
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM

defaults
##    mode                    http
    mode                    tcp
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
#######################################################################
#frontend haproxy
#  mode tcp
#  bind *:80
#  default_backend http-backend
######################################################################
frontend haproxy
  mode tcp
  bind *:443
  default_backend https-backend
#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
backend static
    balance     roundrobin
    server      static 127.0.0.1:4331 check
####################################################################
#backend http-backend
#  mode tcp
#  balance roundrobin
#  server srv1 192.168.10.147:80 check
###################################################################
backend https-backend
  mode tcp
  balance roundrobin
  server srv1 192.168.10.147:443 check
###################################################################
EOF
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --zone=public --add-port=5000/tcp
sudo firewall-cmd --reload
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy

#!/bin/bash
sudo dnf -y update
sudo dnf install haproxy -y
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_org
sudo rm /etc/haproxy/haproxy.cfg
sudo tee /etc/haproxy/haproxy.cfg <<EOF
global
    log         127.0.0.1 local2
    chroot	/var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group	haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http                  ####  tcp, http, health;
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

#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
frontend haproxy
    mode http
    bind *:5000
    default_backend app

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend app
     mode http
     balance    roundrobin                    ## roundrobin, static-rr, leastconn, first, uri, url_param, hdr, rdp-cookie
     server app1 192.168.1.16:8081 check
     server app2 192.168.1.16:8082 check


############### Statistic #######################3
listen stats
    bind :10001
    stats enable
    stats uri /haproxy_stats
    stats auth admin:password
EOF
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --zone=public --permanent --add-port=5000/tcp
sudo firewall-cmd --zone=public --permanent --add-port=10001/tcp
sudo firewall-cmd --reload
sudo setenforce 0
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo systemctl status haproxy

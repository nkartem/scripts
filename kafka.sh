#!/bin/bash
# https://www.how2shout.com/linux/how-to-install-apache-kafka-on-rocky-linux-8-or-almalinux/
# using a minimal
# CPU - 3.4 Ghz (2 cores)
# Memory - 2 GB
# Storage - 20 GB
# Operating System - RHEL 8
#------Start install Kafka-------#
sudo dnf update -y
sudo dnf -y install epel-release
sudo dnf -y install java-11-openjdk
cd /tmp
#sudo wget https://dlcdn.apache.org/kafka/3.0.0/kafka-3.0.0-src.tgz
sudo wget https://dlcdn.apache.org/kafka/3.0.0/kafka_2.13-3.0.0.tgz
tar xzf kafka_2.13-3.0.0.tgz
sudo mv kafka_2.13-3.0.0 /usr/local/kafka
sudo tee /etc/systemd/system/zookeeper.service <<EOF
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/bin/bash /usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
ExecStop=/usr/bin/bash /usr/local/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/kafka.service <<EOF
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/jre-11-openjdk"
ExecStart=/usr/bin/bash /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/bin/bash /usr/local/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper.service
sudo systemctl enable --now kafka.service
# sudo systemctl start zookeeper
# sudo systemctl start kafka
# sudo systemctl status kafka
#------Fihish install Kafka-------#
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
sudo wget https://dlcdn.apache.org/kafka/3.0.0/kafka_2.13-3.1.0.tgz
tar xzf kafka_2.13-3.1.0.tgz
sudo mv kafka_2.13-3.1.0 /usr/local/kafka
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
#After=zookeeper.service #for CentOS8

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/jre-11-openjdk"
ExecStart=/usr/bin/bash /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/bin/bash /usr/local/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable zookeeper
sudo systemctl enable kafka
sudo systemctl start zookeeper
sudo systemctl start kafka
sudo firewall-cmd --zone=public --permanent --add-port 9092/tcp
sudo firewall-cmd --zone=public --permanent --add-port 2181/tcp
sudo firewall-cmd --reload
# sudo systemctl status kafka
# sudo systemctl status zookeeper
#------Fihish install Kafka-------#
#------Start install Docker-------#
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf list docker-ce
sudo dnf install docker-ce --nobest -y
sudo systemctl start docker
sudo systemctl enable docker
sudo dnf install curl -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

sudo docker run --restart=always -p 8080:8080 \
	-e KAFKA_CLUSTERS_0_NAME=local \
	-e KAFKA_CLUSTERS_0_ZOOKEEPER=192.168.10.213 \
	-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=192.168.10.213:9092 \
	-d provectuslabs/kafka-ui:latest 
#------Fihish install Docker-------#
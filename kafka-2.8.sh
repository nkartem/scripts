#!/bin/bash
sudo dnf install -y java-11-openjdk
cd /tmp
sudo wget https://downloads.apache.org/kafka/2.8.2/kafka_2.13-2.8.2.tgz
sudo tar xzf kafka_2.13-2.8.2.tgz
sudo mv kafka_2.13-2.8.2 /opt/kafka
cd /opt/kafka/
sudo tee /etc/systemd/system/zookeeper.service <<EOF
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/bin/bash /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties
ExecStop=/usr/bin/bash /opt/kafka/bin/zookeeper-server-stop.sh
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
ExecStart=/usr/bin/bash /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties
ExecStop=/usr/bin/bash /opt/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now zookeeper.service
sudo systemctl enable --now kafka.service
sudo systemctl status zookeeper.service
sudo systemctl status kafka.service
sudo firewall-cmd --zone=public --permanent --add-port 9092/tcp
sudo firewall-cmd --zone=public --permanent --add-port 9093/tcp
sudo firewall-cmd --zone=public --permanent --add-port 8080/tcp
sudo firewall-cmd --reload
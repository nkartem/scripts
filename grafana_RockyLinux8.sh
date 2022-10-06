#!/bin/bash
sudo dnf install docker netavark -y
#docker run -d --name=prometheus -p 9090:9090 -p 9000:9000 -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
# docker run -d --name=prometheus -p 9090:9090 -p 9000:9000 prom/prometheus
# docker run -d --name=grafana -p 3000:3000 grafana/grafana
sudo firewall-cmd --add-port=9090/tcp --permanent
sudo firewall-cmd --add-port=9100/tcp --permanent
sudo firewall-cmd --add-port=9200/tcp --permanent
sudo firewall-cmd --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
sudo mkdir -p /opt/monitoring/prometheus/data
sudo mkdir -p /opt/monitoring/grafana/provisioning/

sudo chown lion:lion -R /opt/
sudo chmod 777 -R /opt/

cd /opt/monitoring/
sudo tee docker-compose.yaml <<EOF
version: '3.8'

networks:
  monitoring:
    driver: bridge
    
#volumes:
#  prometheus_data:  /opt/monitoring/prometheus/data

services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    expose:
      - 9100
#    ports:
#      - 9100:9100
    environment:
      TZ: "Europe/Kiev"
    networks:
      - monitoring

  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    volumes:
      - /opt/monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
#      - /opt/monitoring/prometheus/data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    expose:
      - 9090
#    ports:
#      - 9090:9090
    environment:
      TZ: "Europe/Kiev"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana
    user: root
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    # volumes:
    #   - ./grafana:/var/lib/grafana
    #   - ./grafana/provisioning/:/etc/grafana/provisioning/
    container_name: grafana
    hostname: grafana
    restart: unless-stopped
    environment:
      TZ: "Europe/Kiev"
    networks:
      - monitoring
# #######Monitoring Containers only Docker
#   cadvisor-exporter:
#     container_name: "cadvisor-exporter"
#     image: google/cadvisor
#     ports:
#       - "9200:8080"
#     volumes:
#       - "/:/rootfs:ro"
#       - "/var/run:/var/run:rw"
#       - "/sys:/sys:ro"
#       - "/var/lib/docker/:/var/lib/docker:ro"
#     restart: unless-stopped
    # networks:
    #   - monitoring
####Monitoring MySQL  
  mysql-exporter:
    image: prom/mysqld-exporter
    container_name: mysql-exporter
    restart: unless-stopped
    environment:
    - DATA_SOURCE_NAME=${MYSQL_USER_EXPORTER}:${MYSQL_PASSWORD_EXPORTER}@(mysql:3306)/
    ports:
      - 9104:9104
    networks:
      - monitoring
    #mem_limit: 128m           # for docker-compose v2 only
    #mem_reservation: 64m      # for docker-compose v2 only
    logging:
        driver: "json-file"
        options:
          max-size: "5m"
EOF

cd  /opt/monitoring/prometheus

sudo tee prometheus.yml<<EOF
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ["localhost:9090"]

  - job_name: node
    static_configs:
    - targets: ['node-exporter:9100']

  - job_name: containers
    static_configs:
    - targets: ['node-exporter:9200']

  - job_name: server123
    static_configs:
    - targets: ['192.168.1.111:9100']
    - targets: ['192.168.1.111:9104']
    - targets: ['192.168.1.111:8088']

  - job_name: 'asterisk_res_prometheus'
    metrics_path: /metrics
    static_configs:
      - targets: ['asterisk_ip:8088']


EOF
sudo chown lion:lion -R /opt/
sudo chmod 777 -R /opt/
cd  /opt/monitoring/
sudo pip3 install podman-compose
#podman-compose up -d
#docker run -d --name=grafana -p 3000:3000 grafana/grafana
# # username: admin
# # password: admin

###1860 
####7362 https://grafana.com/grafana/dashboards/7362-mysql-overview/
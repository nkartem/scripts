#!/bin/bash
#NodeJS  + pm2 + RabbitMQ + postgresql  + pgAdmin + docker + docker-compose
#------Strart install Docker & Docker-compose-------#
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf list docker-ce
sudo dnf install docker-ce --nobest -y
sudo systemctl start docker
sudo systemctl enable docker
sudo dnf install curl -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo  chmod +x /usr/local/bin/docker-compose
sudo  ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
cd /home/user/
sudo doker-compose build
sudo doker-compose up
#------Finish install Docker & Docker-compose-------#
#------Strart install NodeJS-------#
#sudo hostnamectl set-hostname nodejsservtest
sudo dnf -y groupinstall "Development Tools"
sudo dnf -y module list nodejs
sudo dnf -y module install nodejs:14
sudo dnf -y install npm
#------Finish install NodeJS-------#
#------Strart install pm2-------#
sudo npm i -g pm2
#which pm2
#sudo pm2 start app1.js
#sudo pm2 start app2.js
#sudo pm2 list
#------Finish install pm2-------#
#------Strart install RabbitMQ-------#
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y install wget
wget https://github.com/rabbitmq/erlang-rpm/releases/download/v24.1/erlang-24.1-1.el8.x86_64.rpm
sudo dnf install -y erlang-24.1-1.el8.x86_64.rpm
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.8/rabbitmq-server-3.9.8-1.el8.noarch.rpm
sudo dnf install -y rabbitmq-server-3.9.8-1.el8.noarch.rpm
sudo dnf makecache -y --disablerepo='*' --enablerepo='rabbitmq-server'
sudo dnf install -y rabbitmq-server
sudo firewall-cmd --zone=public --permanent --add-port={4369,25672,5671,5672,15672,61613,61614,1883,8883}/tcp
sudo firewall-cmd --reload
sudo systemctl start rabbitmq-server.service
sudo systemctl enable rabbitmq-server.service
sudo rabbitmq-plugins enable rabbitmq_management
sudo cp /home/user/project/jenkins/nodejs/rabbitmq_backup/rabbit_servertransfdev_2021-10-22.json /var/lib/rabbitmq/
sudo rabbitmqctl import_definitions /var/lib/rabbitmq/rabbit_servertransfdev_2021-10-22.json
sudo rabbitmqctl add_user admin2 password
sudo rabbitmqctl set_user_tags admin2 administrator
sudo rabbitmqctl set_permissions -p / admin2 ".*" ".*" ".*"
# chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/
#------Finish install RabbitMQ-------#
#------Strart install postgresql-------#
sudo dnf -y module list postgresql
sudo dnf -y install postgresql-server
sudo postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
#------Finish install postgresql-------#
#------Strart install pgAdmin-------#
sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-1-1.noarch.rpm
sudo dnf -y install pgadmin4-web
sudo dnf -y install policycoreutils-python-utils
sudo firewall-cmd --add-port=80/tcp --permanent
sudo firewall-cmd --reload
sudo setsebool -P httpd_can_network_connect 1
sudo /usr/pgadmin4/bin/setup-web.sh --yes
sudo -u postgres psql
##postgres=# \password
##postgres=# create database mydb
###postgres=# create user myuser with encrypted password 'mypass'
###postgres=# grant all privileges on database mydb to myuser
##sudo su nano /var/lib/pgsql/data/pg_hba.conf
##local	all	all	trust
##host	all	127.0.0.1/32	trust
##sudo systemctl restart postgresql
##http://server-ip/pgadmin4
#------Finish install pgAdmin-------#
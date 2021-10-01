#!/bin/bash
sudo apt -y update
sudo apt -y upgrade
sudo apt -y install openjdk-11-jdk
sudo ufw enable
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt -y update
sudo apt -y install jenkins
sudo systemctl start jenkins
sudo ufw allow 8080
#sudo cat /var/lib/jenkins/secrets/initialAdminPassword (take from console)
#!/bin/bash
#reset password root
sudo systemctl stop mysql
sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables --skip-networking"
sudo systemctl start mysql
# change password
sudo mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('mysql');"
mysql -u root -pmysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('1123456');"
#Enter password:
#0300
#SET PASSWORD FOR 'root'@'localhost' = PASSWORD('111111');
#exit
##SET PASSWORD FOR 'root'@'localhost' = PASSWORD('123456');

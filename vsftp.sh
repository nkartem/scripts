#1/bin/sh
# Rocky Linux 8, RHEL 8  https://computingforgeeks.com/configure-vsftpd-ftp-server-on-rocky-almalinux/
# Install vsftpd
sudo yum update -y
sudo yum install vsftpd openssl -y
sudo systemctl start vsftpd
sudo systemctl enable vsftpd --now
sudo systemctl status vsftpd
# Create FTP user and Its Directory
sudo adduser vsftpduser
sudo passwd vsftpduser
sudo mkdir -p /home/vsftpduser/ftp_folder
sudo chmod -R 750 /home/vsftpduser/ftp_folder
sudo chown vsftpduser: /home/vsftpduser/ftp_folder
sudo bash -c 'echo vsftpduser >> /etc/vsftpd/user_list'
# vsftpd Configuaration
sudo cp /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf_org
sudo rm /etc/vsftpd/vsftpd.conf
sudo tee /etc/vsftpd/vsftpd.conf <<EOF
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
chroot_local_user=YES
###################
allow_writeable_chroot=YES
pasv_min_port=30000
pasv_max_port=31000
userlist_file=/etc/vsftpd/user_list
userlist_enable=YES
userlist_deny=NO
#################
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
#############################
#Enable SSL##
ssl_enable=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
rsa_cert_file=/etc/vsftpd/vsftpd.pem
rsa_private_key_file=/etc/vsftpd.pem
EOF

# Open FTP Ports on Firewalld
sudo firewall-cmd --permanent --add-port=20-21/tcp
sudo firewall-cmd --permanent --add-port=30000-31000/tcp
sudo firewall-cmd --reload

# openssl
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/vsftpd.pem -out /etc/vsftpd/vsftpd.pem
sudo systemctl restart vsftpd
#https://www.atlantic.net/vps-hosting/how-to-create-a-sftp-user-without-shell-access-on-centos-8/
#!/bin/bash
sudo dnf update -y
sudo adduser sftp
sudo passwd sftp
sudo mkdir -p /opt/sftp/public
sudo chown root:root /opt/sftp
sudo chmod 755 /opt/sftp
sudo chown sftp:sftp /opt/sftp/public
sudo tee -a /etc/ssh/sshd_config <<EOF
Match User sftp
ForceCommand internal-sftp
PasswordAuthentication yes
ChrootDirectory /opt/sftp
PermitTunnel no
AllowAgentForwarding no
AllowTcpForwarding no
X11Forwarding no
EOF
sudo systemctl restart sshd
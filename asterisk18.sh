#!/bin/bash
# RHEL 8
# https://newadmin.ru/ustanovka-asterisk-18-na-centos-8/
#sudo yum -y update
#sudo systemctl reboot
sudo timedatectl set-timezone Europe/Kiev
mkdir install
cd install

sudo firewall-cmd --permanent --add-port=5060/{tcp,udp}
sudo firewall-cmd --permanent --add-port=5061/{tcp,udp}
sudo firewall-cmd --reload

sudo setenforce 0
sudo sed -i 's/\(^SELINUX=\).*/\SELINUX=permissive/' /etc/selinux/config
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
ARCH=$( /bin/arch )
sudo subscription-manager repos --enable "codeready-builder-for-rhel-8-${ARCH}-rpms"
sudo yum group -y install "Development Tools"
sudo yum -y install git wget vim  net-tools sqlite-devel psmisc ncurses-devel libtermcap-devel newt-devel libxml2-devel libtiff-devel gtk2-devel libtool libuuid-devel subversion kernel-devel kernel-devel-$(uname -r) crontabs cronie-anacron libedit libedit-devel
#Jansson
git clone https://github.com/akheron/jansson.git
cd jansson
autoreconf -i
./configure --prefix=/usr/
make
sudo make install
#PJSIP
git clone https://github.com/pjsip/pjproject.git
cd pjproject
./configure CFLAGS="-DNDEBUG -DPJ_HAS_IPV6=1" --prefix=/usr --libdir=/usr/lib64 --enable-shared --disable-video --disable-sound --disable-opencore-amr
make dep
make
sudo make install
sudo ldconfig
#Asterisk
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
tar xvfz asterisk-18-current.tar.gz
cd asterisk-18*/

sudo ./contrib/scripts/install_prereq install
make distclean
sudo ./contrib/scripts/get_mp3_source.sh
sudo ./configure --libdir=/usr/lib64

make menuselect.makeopts
menuselect/menuselect \
        --enable app_authenticate --enable app_cdr --enable app_celgenuserevent \
        --enable app_channelredirect --enable app_chanisavail --enable app_chanspy \
		--enable chan_ooh323 --enable format_mp3 --enable format_wav --enable codec_ulaw \
		--enable CORE-SOUNDS-EN-WAV --enable CORE-SOUNDS-EN-ULAW \
  		--enable MOH-OPSOUND-WAV --enable MOH-OPSOUND-ULAW \
		--enable EXTRA-SOUNDS-EN-WAV --enable EXTRA-SOUNDS-EN-ULAW

#make menuselect
sudo make
sudo make install
#sudo make install WGET_EXTRA_ARGS="--no-verbose"
sudo make samples
sudo make config
sudo ldconfig
sudo make install-logrotate
# add user
# sudo groupadd asterisk
# sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
# sudo usermod -aG audio,dialout asterisk
# sudo chown -R asterisk.asterisk /etc/asterisk /var/{lib,log,spool}/asterisk /usr/lib64/asterisk

# sudo tee /etc/sysconfig/asterisk <<EOF
# AST_USER="asterisk"
# AST_GROUP="asterisk"
# EOF

# sudo tee /etc/asterisk/asterisk.conf <<EOF
# runuser = asterisk ; The user to run as.
# rungroup = asterisk ; The group to run as.
# EOF

sudo systemctl restart asterisk
sudo systemctl enable asterisk
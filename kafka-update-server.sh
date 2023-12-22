#/bin/sh
sudo systemctl stop kafka
sudo systemctl stop zookeeper
sudo dnf update -y
sudo reboot
ls /opt/
sudo systemctl start zookeeper
sudo systemctl status zookeeper
sudo systemctl start kafka
sudo systemctl status kafka


if sudo systemctl is-active kafka 
then 
    echo "Service is active. Test passed."
        exit 0
else 
    echo "Service is not active. Test failed."
    sudo rm /tmp/kafka-logs/meta.properties
    sudo systemctl start kafka
    sudo systemctl status kafka
    exit 1
fi
exit

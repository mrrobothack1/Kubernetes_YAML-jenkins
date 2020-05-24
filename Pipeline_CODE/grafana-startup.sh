#!bin/bash

#mount data-disk
sudo mkdir -p /grafana
sudo mount -o discard,defaults /dev/sdb /grafana/
sudo chmod a+w /grafana/
val="$(sudo blkid /dev/sbd | cut -d '"' -f2)"
sudo echo "UUID=$val /grafana ext4 discard,defaults,nofail 0 2" >> /etc/fstab
sudo systemctl stop jenkins
sudo rm -rf  /var/lib/jenkins/ /var/log/jenkins/ /var/cache/jenkins/

#Steps to Start GRAFANA
cd  /
cd grafana/grafana/grafana-6.1.6/
cd data/plugins/mongodb-grafana
nohup npm run server &
cd ../../../
nohup ./grafana-server web &
cd bin/
nohup ./grafana-server web &
netstat -ntlp

#status of grafana
sudo systemctl status grafana

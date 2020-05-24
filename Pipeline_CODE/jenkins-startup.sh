#!bin/bash

#to mount
sudo mkdir -p /jenkins
sudo mount -o discard,defaults /dev/sdb /jenkins
val="$(sudo blkid /dev/sbd | cut -d '"' -f2)"
sudo echo "UUID=$val /jenkins ext4 discard ext4 discard,default,nofail 0 2" >> /etc/fstab
sudo systemctl stop jenkins
sudo chown  -R jenkins:jenkins /jenkins
sudo chown  -R jenkins:jenkins /var/cache/jenkins
sudo chown  -R jenkins:jenkins /var/log/jenkins


#to install Docker

sudo yum install -y yum-utils device-mapper-presistant-data lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce-18.09.0-3.e17.x86_64


#install go
sudo yum update -y
sudo yum install wget -y
wget https://dl.google.com/go/go1.11.4.linux-amd64.tar.gz
tar -xvf go1.11.4.linux-amd64.tar.gz
sudo mv go /usr/local
export GOROOT=/usr/local/go >> $HOME/.bash_profile
export PATH=$PATH:$GOROOT/bin >> $HOME/.bash_profile
source ~/.bash_profile

#INSTALL k8s

FILE="/etc/yum.repos.d/kubernetes.repo"
cat <<EOF >$FILE
[kubernetes]
name=kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-e17-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

sudo yum update && sudo apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo yum update
sudo yum install -y kubectl

#start docker and jenkins

sudo systemctl start docker
sudo systemctl start jenkins

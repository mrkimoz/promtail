#!/bin/bash
# Script to install dependencies 
# By : Mohamed Kamal


HOSTNAME=$(hostname)
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install docker-ce -y
systemctl start docker
systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
mkdir /etc/promtail
cd /etc/promtail
wget https://raw.githubusercontent.com/mrkimoz/promtail/refs/heads/main/docker-compose.yaml
wget https://raw.githubusercontent.com/mrkimoz/promtail/refs/heads/main/promtail-config.yml
sed -i "s/FTSO/$HOSTNAME/" promtail-config.yml
docker-compose up -d
pm2 install pm2-metrics
apt install -y nginx
systemctl restart nginx
systemctl enable nginx
cd /etc/nginx/sites-available/
wget https://raw.githubusercontent.com/mrkimoz/promtail/refs/heads/main/prom-pm2
sed -i "s/ServerIP/$PUBLIC_IP/" prom-pm2
ln -s /etc/nginx/sites-available/prom-pm2 /etc/nginx/sites-enabled/
systemctl restart nginx

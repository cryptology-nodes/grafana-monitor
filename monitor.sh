#!/bin/bash
exists()
{
  command -v "$1" >/dev/null 2>&1
}
if exists curl; then
	echo ''
else
  sudo apt update && sudo apt install curl -y < "/dev/null"
fi

sleep 1 && curl -s https://raw.githubusercontent.com/cryptology-nodes/main/main/logo.sh |  bash && sleep 2

bash_profile=$HOME/.bash_profile
if [ -f "$bash_profile" ]; then
    . $HOME/.bash_profile
fi

#update and install new packages
echo -e '\n\e[42mUpdate and install new packages\e[0m\n' && sleep 1
sudo apt update
sudo apt install \
    ca-certificates \
    gnupg \
    lsb-release
# add docker gpg keys
echo -e '\n\e[42m add docker gpg keys\e[0m\n' && sleep 1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
#add docker stable repo
echo -e '\n\e[42m add docker gpg keys \e[0m\n' && sleep 1
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#update and install docker
echo -e '\n\e[42m update and install docker \e[0m\n' && sleep 1
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
apt  install docker-compose

#install node exporter
echo -e '\n\e[42m install node exporter \e[0m\n' && sleep 1
touch
cat << EOF >> docker-compose.yml
version: '3.3'

networks:
  monitoring:
    driver: bridge

volumes:
  prometheus_data: {}

services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - 9100:9100
    networks:
      - monitoring
EOF
#start docker image
echo -e '\n\e[42m start docker image \e[0m\n' && sleep 1

docker-compose up -d

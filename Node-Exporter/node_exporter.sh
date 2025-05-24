#!/bin/bash
VERSION="1.9.1"
sudo su
sudo apt update -y
sudo apt upgrade -y

sudo groupadd -f node_exporter
sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/node_exporter
sudo chown -R node_exporter:node_exporter /etc/node_exporter
sudo apt install -y wget 

sudo wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
sudo tar -xvf node_exporter-$VERSION.linux-amd64.tar.gz
sudo rm -rf node_exporter-$VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$VERSION.linux-amd64 node_exporter-files
sudo cp node_exporter-files/node_exporter /usr/bin/
sudo chown -R node_exporter:node_exporter /usr/bin/node_exporter

sudo id -u node_exporter &>/dev/null || useradd --no-create-home --shell /bin/false node_exporter

# Create systemd service
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
ExecStart=/usr/bin/node_exporter --web.listen-address=:9100

[Install]
WantedBy=multi-user.target
EOF
sudo chmod -R /usr/lib/systemd/system/node_exporter.service

# # Reload and enable service
# sudo systemctl daemon-reload
# sudo systemctl enable node_exporter
# sudo systemctl start  node_exporter
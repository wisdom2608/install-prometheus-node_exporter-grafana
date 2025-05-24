#!/bin/bash
# Create prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create required directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus

# Download and extract Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.48.1/prometheus-2.48.1.linux-amd64.tar.gz
tar xvf prometheus-2.48.1.linux-amd64.tar.gz
sudo rm -rf prometheus-2.48.1.linux-amd64.tar.gz
cd prometheus-2.48.1.linux-amd64

# Move binaries
sudo cp prometheus promtool /usr/local/bin/

# Copy config and consoles
sudo cp -r consoles console_libraries /etc/prometheus
sudo cp prometheus.yml /etc/prometheus

# Set ownership and permissions
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus /usr/local/bin/prometheus /usr/local/bin/promtool
sudo chmod 775 /usr/local/bin/prometheus /usr/local/bin/promtool

# Create systemd service file for Prometheus
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries \\
    --web.listen-address=0.0.0.0:9090
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo chmod -R /usr/lib/systemd/system/prometheus.service
# Reload systemd and start Prometheus
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus 
sudo systemctl status prometheus --no-pager



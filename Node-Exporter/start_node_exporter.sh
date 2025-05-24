#!/bin/bash
sudo chmod 644 /etc/systemd/system/node_exporter.service
sudo chown node_exporter:node_exporter /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter --no-pager


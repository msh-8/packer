#!/usr/bin/bash
sudo echo "network: {config: disabled}" > /home/ubuntu/99-disable-network-config.cfg
sudo cp /home/ubuntu/99-disable-network-config.cfg /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
sudo cp /home/ubuntu/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
sudo chmod 600 /etc/netplan/00-installer-config.yaml

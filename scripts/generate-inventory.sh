#!/bin/bash
set -e

echo "Generating Ansible inventory from Multipass VM IPs..."

CONTROLLER_IP=$(multipass info slurm-controller | awk '/IPv4/ {print $2}')
NODE1_IP=$(multipass info slurm-node1 | awk '/IPv4/ {print $2}')
NODE2_IP=$(multipass info slurm-node2 | awk '/IPv4/ {print $2}')

if [ -z "$CONTROLLER_IP" ] || [ -z "$NODE1_IP" ] || [ -z "$NODE2_IP" ]; then
  echo "ERROR: Could not get IP for one or more VMs. Are they running?"
  multipass list
  exit 1
fi

mkdir -p ansible

cat > ansible/inventory.ini << EOF
[controller]
slurm-controller ansible_host=$CONTROLLER_IP ansible_user=ubuntu

[compute]
slurm-node1 ansible_host=$NODE1_IP ansible_user=ubuntu
slurm-node2 ansible_host=$NODE2_IP ansible_user=ubuntu

[all:children]
controller
compute
EOF

echo "Inventory written to ansible/inventory.ini:"
cat ansible/inventory.ini

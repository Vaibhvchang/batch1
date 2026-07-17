#!/bin/bash
set -e

# SSH_KEY env var is set by the "Ensure SSH key" workflow step.
# Fall back to common key paths if running outside the workflow.
if [ -z "$SSH_KEY" ]; then
  if [ -f ~/.ssh/id_ed25519 ]; then
    SSH_KEY=~/.ssh/id_ed25519
  else
    SSH_KEY=~/.ssh/id_rsa
  fi
fi

echo "Generating Ansible inventory from Multipass VM IPs..."
echo "Using SSH key: $SSH_KEY"

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
slurm-controller ansible_host=$CONTROLLER_IP ansible_user=ubuntu ansible_ssh_private_key_file=$SSH_KEY

[compute]
slurm-node1 ansible_host=$NODE1_IP ansible_user=ubuntu ansible_ssh_private_key_file=$SSH_KEY
slurm-node2 ansible_host=$NODE2_IP ansible_user=ubuntu ansible_ssh_private_key_file=$SSH_KEY

[all:children]
controller
compute
EOF

echo "Inventory written to ansible/inventory.ini:"
cat ansible/inventory.ini

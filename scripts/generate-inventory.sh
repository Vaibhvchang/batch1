#!/bin/bash
set -e

echo "Generating Ansible inventory (multipass connection — no SSH required)..."

# Verify VMs are running
for vm in slurm-controller slurm-node1 slurm-node2; do
  STATUS=$(multipass info "$vm" | awk '/State/ {print $2}')
  if [ "$STATUS" != "Running" ]; then
    echo "ERROR: VM '$vm' is not running (status: $STATUS)"
    exit 1
  fi
  echo "$vm is Running"
done

mkdir -p ansible

cat > ansible/inventory.ini << 'EOF'
# Uses community.general.multipass connection — no SSH keys needed.
# Ansible runs commands via: multipass exec <vm-name> -- <command>

[controller]
slurm-controller ansible_connection=community.general.multipass

[compute]
slurm-node1 ansible_connection=community.general.multipass
slurm-node2 ansible_connection=community.general.multipass

[all:children]
controller
compute

[all:vars]
ansible_user=ubuntu
EOF

echo "Inventory written to ansible/inventory.ini:"
cat ansible/inventory.ini

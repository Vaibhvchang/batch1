#!/bin/bash
set -e

echo "Generating Ansible inventory (multipass exec transport — no SSH keys needed)..."

# Verify VMs are running
for vm in slurm-controller slurm-node1 slurm-node2; do
  STATUS=$(multipass info "$vm" | awk '/State/ {print $2}')
  if [ "$STATUS" != "Running" ]; then
    echo "ERROR: VM '$vm' is not running (status: $STATUS)"
    exit 1
  fi
  echo "$vm is Running"
done

# Absolute path to the SSH wrapper (required by ansible_ssh_executable)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_WRAPPER="$SCRIPT_DIR/multipass-ssh.sh"
chmod +x "$SSH_WRAPPER"

mkdir -p ansible

cat > ansible/inventory.ini << EOF
# Ansible connects via multipass exec, not real SSH.
# ansible_ssh_executable points to a wrapper that calls: multipass exec <vm> -- <cmd>

[controller]
slurm-controller

[compute]
slurm-node1
slurm-node2

[all:children]
controller
compute

[all:vars]
ansible_user=ubuntu
ansible_ssh_executable=$SSH_WRAPPER
ansible_ssh_common_args=
ansible_pipelining=true
ansible_python_interpreter=/usr/bin/python3
EOF

echo "Inventory written to ansible/inventory.ini:"
cat ansible/inventory.ini

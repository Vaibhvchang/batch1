#!/bin/bash
set -e

VMS=(slurm-controller slurm-node1 slurm-node2)

for vm in "${VMS[@]}"; do
  if multipass info "$vm" &>/dev/null 2>&1; then
    echo "VM '$vm' already exists, skipping."
  else
    echo "Creating VM: $vm ..."
    multipass launch 24.04 --name "$vm" --cpus 2 --memory 2G --disk 10G
    echo "VM '$vm' created."
  fi
done

echo "All VMs ready:"
multipass list

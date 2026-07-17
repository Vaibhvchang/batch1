#!/bin/bash
# Ansible SSH wrapper — routes all SSH calls through "multipass exec"
# Ansible calls: multipass-ssh.sh [ssh-flags] [user@]hostname [command...]
# This script strips SSH flags, extracts the VM name, and runs via multipass exec.

VM=""
REMOTE_CMD=()
skip_next=false

for arg in "$@"; do
  if $skip_next; then
    skip_next=false
    continue
  fi
  case "$arg" in
    # SSH options that consume the next argument — skip both
    -l|-o|-i|-p|-F|-E|-J|-W|-w|-b|-c|-D|-e|-I|-L|-m|-O|-Q|-R|-S)
      skip_next=true ;;
    # Standalone SSH flags — skip
    -*)
      ;;
    # First positional arg is the hostname (strip optional user@ prefix)
    *)
      if [ -z "$VM" ]; then
        VM="${arg##*@}"
      else
        REMOTE_CMD+=("$arg")
      fi
      ;;
  esac
done

if [ -z "$VM" ]; then
  echo "multipass-ssh: could not determine VM name from args: $*" >&2
  exit 1
fi

if [ ${#REMOTE_CMD[@]} -eq 0 ]; then
  exec multipass exec "$VM" -- bash
else
  exec multipass exec "$VM" -- "${REMOTE_CMD[@]}"
fi

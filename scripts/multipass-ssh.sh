#!/bin/bash
# Ansible SSH wrapper — routes all SSH calls through "multipass exec"
# Ansible calls: multipass-ssh.sh [ssh-flags] [user@]hostname [remote-command...]
#
# Key rule: once the hostname is found, ALL remaining args are the remote
# command — stop parsing SSH flags to avoid misinterpreting remote args
# like "-c" (shell's command flag) as SSH options.

VM=""
REMOTE_CMD=()
skip_next=false
found_hostname=false

for arg in "$@"; do
  # Once hostname is found, collect everything as the remote command
  if $found_hostname; then
    REMOTE_CMD+=("$arg")
    continue
  fi

  if $skip_next; then
    skip_next=false
    continue
  fi

  case "$arg" in
    # SSH options that consume the next argument — skip both
    -l|-o|-i|-p|-F|-E|-J|-W|-w|-b|-e|-I|-L|-m|-O|-Q|-R|-S)
      skip_next=true ;;
    # Standalone SSH flags — skip
    -*)
      ;;
    # First positional arg is the hostname
    *)
      VM="${arg##*@}"   # strip optional user@ prefix
      found_hostname=true
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

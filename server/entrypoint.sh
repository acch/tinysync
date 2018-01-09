#!/bin/ash

# Check if environment is defined
if [ "$AUTHORIZED_KEYS" == "none" ]
then
  echo "ERROR: Please provide your public SSH key(s) using the AUTHORIZED_KEYS environment variable!" >&2
  exit 1
fi

# Add authorized keys
IFS=$'\n'
for key in $(echo $AUTHORIZED_KEYS | tr "," "\n")
do
  trimmed_key=$(echo $key | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  echo "Adding authorized key \"${trimmed_key}\"..."
  echo $trimmed_key >> /home/tinysync/.ssh/authorized_keys
done

# Generate host keys if they do not exist
ssh-keygen -A

# Start SSH Daemon in foreground
exec /usr/sbin/sshd -D -e "$@" 2>&1

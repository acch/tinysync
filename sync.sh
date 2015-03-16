#!/bin/bash

#
# sync.sh - synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Version: 1.10
# Depends: openssh, rsync
#
# To activate scheduled snycing, add the following line to your crontab (crontab -e):
# */10 * * * * /home/achim/bin/sync.sh &>> /var/log/sync.err
#

# -------------- Options --------------
directory=".secret_encfs"
local_user="???"
remote_user="tinysync"
key="/home/$local_user/.ssh/id_rsa_tinysync"
#key="/home/$local_user/.ssh/id_rsa"
host="???"
logfile="/var/log/sync.log"
local_lockfile="/tmp/sync.lck"
remote_lockfile="/tmp/sync.lck"
maxwait=10
port=1602
interface=em1
# -------------------------------------

acquire_local_lock () {
  # Check for existence of local lock
  if [ -f "$local_lockfile" ]; then
    # Lock exists, another instance seems to be running
    echo "[`date`] Already running - will exit now!" >> $logfile
    return 1
  fi

  # Acquire local lock
  hostname > $local_lockfile
}

acquire_server_lock () {
  # Check for existence of server lock
  if $rsh [ -f "$remote_lockfile" ]; then
    # Lock exists, another instance seems to be running
    echo "[`date`] Server locked - will exit now!" >> $logfile
    return 1
  fi

  # Acquire server lock
  $rsh touch $remote_lockfile
}

release_local_lock () {
  # Release local lock
  if [ -f "$local_lockfile" ]; then
    rm $local_lockfile
  fi
}

release_server_lock () {
  # Release server lock
  if $rsh [ -f "$remote_lockfile" ]; then
    $rsh rm $remote_lockfile
  fi
}

check_network () {
  # Check for $interface
  if ! grep -q up /sys/class/net/$interface/operstate; then
    echo "[`date`] $interface down - will exit now!" >> $logfile
    return 1
  fi

  # Check for internet connection
  if ! ping -c 1 www.google.com &> /dev/null; then
    echo "[`date`] No network - will exit now!" >> $logfile
    return 1
  fi

  # Check for ssh connectivity
  if ! $rsh ls &> /dev/null; then
    echo "[`date`] No SSH connection - will exit now!" >> $logfile
    return 1
  fi
}

check_local_dir () {
  # Check for existence of local directory
  if [ ! -d "/home/$local_user/$directory" ]; then
    # Initialize local directory
    mkdir /home/$local_user/$directory
    return 1
  fi
}

check_server_dir () {
  # Check for existence of server directory
  if $rsh [ ! -d "/home/$remote_user/$directory" ]; then
    # Initialize server directory
    $rsh mkdir /home/$remote_user/$directory
    return 1
  fi
}

sync_down () {
  # Check what syncing down would do
  changes=$($rsync_test -e "$rsync_ssh_opts" $host:/home/$remote_user/$directory /home/$local_user/ 2>> $logfile | wc -l)

  if [ "$changes" -gt 4 ]; then
    # Log what we're about to do
    echo "[`date`] Downloading $(( $changes - 4 )) changes." >> $logfile
    #notify-send -i down sync.sh "Downloading $(( $changes - 4 )) changes..."

    # Download changes
    $rsync -e "$rsync_ssh_opts" $host:/home/$remote_user/$directory /home/$local_user/ &>> $logfile

    # Check for errors
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi
}

sync_up () {
  # Check what syncing up would do
  changes=$($rsync_test -e "$rsync_ssh_opts" /home/$local_user/$directory $host:/home/$remote_user/ 2>> $logfile | wc -l)

  if [ "$changes" -gt 4 ]; then
    # Log what we're about to do
    echo "[`date`] Uploading $(( $changes - 4 )) changes." >> $logfile
    #notify-send -i up sync.sh "Uploading $(( $changes - 4 )) changes..."

    # Upload changes
    $rsync -e "$rsync_ssh_opts" /home/$local_user/$directory $host:/home/$remote_user/ &>> $logfile

    # Check for errors
    if [ $? -ne 0 ]; then
      return 1
    fi
  fi
}

init_log () {
  # Check for existence of log file
  if [ ! -f "$logfile" ]; then
    # Initialize new log file
    echo "[`date`] Starting up!" > $logfile
  fi 
}

prune_log () {
  # Check size of log file
  if [ $(wc -l "$logfile" | cut -d ' ' -f 1) -gt 150 ]; then
    # Make sure log file doesn't grow too big
    tail -n 100 $logfile > /tmp/sync.log.tmp
    cat /tmp/sync.log.tmp > $logfile
    rm /tmp/sync.log.tmp
  fi
}

# Check for force option
if [ $# -gt 0 ] && [ "$1" == "--force" ]; then force=1
else force=0
fi

# Compile SSH command
rsh="/usr/bin/ssh \
  -o PasswordAuthentication=no \
  -o PubkeyAuthentication=yes \
  -l $remote_user \
  -i $key \
  -p $port \
  $host"

# Compile RSYNC command
rsync_test="/usr/bin/rsync \
  -vnauz --delete"
rsync="/usr/bin/rsync \
  -auz --delete"
rsync_ssh_opts="/usr/bin/ssh \
  -l $remote_user \
  -i $key \
  -p $port"


#
# Main starts here
#

# Initialize
init_log

# Check for another instance running
if ! acquire_local_lock; then
  exit 1
fi

# Sleep up to 10 secs (force option overrides)
if [ "$force" -eq 0 ]; then sleep $(( $RANDOM % $maxwait )); fi

# Check for connectivity (force option overrides)
if [ "$force" -eq 1 ] || check_network; then
  # Check for another instance running on server
  if acquire_server_lock; then
    # Check for existence of local copy
    if ! check_local_dir; then
      # Download server copy
      sync_down
    # Check for existence of server copy
    elif ! check_server_dir; then
      # Find latest mtime in local copy
      local_mtime=$(find /home/$local_user/$directory -printf "%Ts\n" | sort -g | tail -n 1)

      # Upload local copy
      if sync_up; then
        # Update server copy's timestamp on success
        $rsh "echo $local_mtime > /home/$remote_user/sync.tim"
      fi
    else
      # Find latest mtime in local and server copy
      local_mtime=$(find /home/$local_user/$directory -printf "%Ts\n" | sort -g | tail -n 1)
#      server_mtime=$($rsh "find $homedir/$directory -printf '%Ts\n' | sort -g | tail -n 1")
      server_mtime=$($rsh "cat /home/$remote_user/sync.tim")

      # Compare mtimes
      if [ "$local_mtime" -lt "$server_mtime" ]; then
        # Server copy is newer, download it
        sync_down
      elif [ "$local_mtime" -gt "$server_mtime" ]; then
        # Local copy is newer, upload it
        if sync_up; then
          # Update server copy's timestamp on success
          $rsh "echo $local_mtime > /home/$remote_user/sync.tim"
        fi
      fi
      # If copies are already in sync, do nothing
    fi

    # Clean up server
    release_server_lock
  fi
fi

# Clean up
prune_log
release_local_lock

exit 0

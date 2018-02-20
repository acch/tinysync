#!/bin/bash

#
# Tinysync - Simple tool for keeping a directory synchronized between multiple computers
# sync.sh - synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Depends: openssh, rsync
# Version: 1.3.1
#
# To activate scheduled syncing, run this script periodically (e.g. via systemd timer)
#

# Ignore linter errors
# shellcheck disable=SC2086
# shellcheck disable=SC2154

# Treat unset variables as errors
set -u

# Gather information about the environment
basedir=$(dirname "$0")
date="/usr/bin/date -R"
local_user=$(whoami)
interface=""


# Sanity checks
if [ ! -x /usr/bin/ssh ]; then
  echo "[$($date)] 'openssh' not found - please install it!"
  exit 1
fi

if [ ! -x /usr/bin/rsync ]; then
  echo "[$($date)] 'rsync' not found - please install it!"
  exit 1
fi


load_config () {
  # Load configuration from file
  if [ ! -f "$basedir/sync.conf" ]; then
    echo "[$($date)] Config file not found: $basedir/sync.conf"
    echo "Please copy the sample config file and edit it accordingly!"
    return 1
  fi

  # shellcheck source=/dev/null
  source $basedir/sync.conf

  # Compile SSH command
  rsh="/usr/bin/ssh \
    -o PasswordAuthentication=no \
    -o PubkeyAuthentication=yes \
    -l $remote_user \
    -i $ssh_key \
    -p $ssh_port \
    -o ControlMaster=auto
    -o ControlPath=~/.ssh/sync-%C
    -o ControlPersist=$(( auto_wait + sched_wait + 5 ))
    $host"

  # Compile RSYNC command
  rsync_test="/usr/bin/rsync \
    -vnauz --delete"
  rsync="/usr/bin/rsync \
    -auz --delete"
  rsync_ssh_opts="/usr/bin/ssh \
    -o PasswordAuthentication=no \
    -o PubkeyAuthentication=yes \
    -l $remote_user \
    -i $ssh_key \
    -p $ssh_port \
    -o ControlMaster=auto
    -o ControlPath=~/.ssh/sync-%C
    -o ControlPersist=$(( auto_wait + sched_wait + 5 ))"

  return 0
}


acquire_local_lock () {
  # Check for existence of local lock
  if [ -f "$local_lockfile" ]; then
    # Lock exists, another instance seems to be running
    echo "[$($date)] Already running - will exit now!" >> $logfile
    return 1
  fi

  # Acquire local lock
  touch $local_lockfile

  return 0
}


acquire_server_lock () {
  # Check for existence of server lock
  if $rsh [ -f "$remote_lockfile" ]; then
    # Lock exists, another instance seems to be running
    echo "[$($date)] Server locked - will exit now!" >> $logfile
    return 1
  fi

  # Acquire server lock
  $rsh touch $remote_lockfile

  return 0
}


release_server_lock () {
  # Release server lock
  $rsh [ -f "$remote_lockfile" ] && $rsh rm $remote_lockfile
}


release_local_lock () {
  # Release local lock
  [ -f "$local_lockfile" ] && rm $local_lockfile
}


check_network () {
  # Check for $interface
  if [ ! -z "$interface" ] && ! grep -q up /sys/class/net/$interface/operstate; then
    echo "[$($date)] $interface down - will exit now!" >> $logfile
    return 1
  fi

  # Check for internet connection
  if ! ping -c 1 www.google.com &> /dev/null; then
    echo "[$($date)] No network - will exit now!" >> $logfile
    return 1
  fi

  # Check for ssh connectivity
  if ! $rsh ls &> /dev/null; then
    echo "[$($date)] No SSH connection - will exit now!" >> $logfile
    return 1
  fi

  return 0
}


check_local_dir () {
  # Check for existence of local directory
  if [ ! -d "/home/$local_user/$directory" ]; then
    # Initialize local directory
    mkdir /home/$local_user/$directory
    return 1
  fi

  return 0
}


check_server_dir () {
  # Check for existence of server directory
  if $rsh [ ! -d "/home/$remote_user/$directory" ]; then
    # Initialize server directory
    $rsh mkdir /home/$remote_user/$directory
    return 1
  fi

  return 0
}


sync_down () {
  # Check what syncing down would do
  changes=$($rsync_test -e "$rsync_ssh_opts" $host:/home/$remote_user/$directory /home/$local_user/ 2>> $logfile | wc -l)

  if [ "$changes" -gt 4 ]; then
    # Log what we're about to do
    echo "[$($date)] Downloading $(( changes - 4 )) changes." >> $logfile

    # Download changes
    $rsync -e "$rsync_ssh_opts" $host:/home/$remote_user/$directory /home/$local_user/ &>> $logfile || return 1
  fi

  return 0
}


sync_up () {
  # Check what syncing up would do
  changes=$($rsync_test -e "$rsync_ssh_opts" /home/$local_user/$directory $host:/home/$remote_user/ 2>> $logfile | wc -l)

  if [ "$changes" -gt 4 ]; then
    # Log what we're about to do
    echo "[$($date)] Uploading $(( changes - 4 )) changes." >> $logfile

    # Upload changes
    $rsync -e "$rsync_ssh_opts" /home/$local_user/$directory $host:/home/$remote_user/ &>> $logfile || return 1
  fi

  return 0
}


init_log () {
  # Check for existence of log file and initialize if necessary
  [ -f "$logfile" ] || echo "[$($date)] Starting up!" > $logfile
}


prune_log () {
  # Check size of log file
  if [ "$(wc -l $logfile | cut -d ' ' -f 1)" -gt 150 ]; then
    # Make sure log file doesn't grow too big
    tail -n 100 $logfile > /tmp/sync.log.tmp
    cat /tmp/sync.log.tmp > $logfile
    rm /tmp/sync.log.tmp
  fi
}


###############################################################################
# Main starts here
###############################################################################

# Load configuration
load_config || exit 1

# Check for force option
if [ $# -gt 0 ] && [ "$1" == "--force" ]; then
  force=1
else
  force=0
fi

# Initialize
init_log

# Check for another instance running
acquire_local_lock || exit 1

# Ensure local lock is released upon exit
trap "release_local_lock; exit" INT TERM EXIT

# Sleep up to $sched_wait seconds (force option overrides)
[ "$force" -eq 1 ] || sleep $(( RANDOM % sched_wait ))

# Check for connectivity (force option overrides)
if [ "$force" -eq 1 ] || check_network; then

  # Check for another instance running on server
  if acquire_server_lock; then

    # Ensure server lock is released upon exit
    trap "release_server_lock; release_local_lock; exit" INT TERM EXIT

    # Check for existence of local copy
    if ! check_local_dir; then

      # Download server copy
      sync_down

    # Check for existence of server copy
    elif ! check_server_dir; then

      # Find latest mtime in local copy
      local_mtime=$(find /home/$local_user/$directory -printf "%Ts\n" | sort -g | tail -n 1)

      # Upload local copy, then update server copy's timestamp on success
      sync_up && $rsh "echo $local_mtime > /home/$remote_user/sync.tim"

    # Local copy and server copy exist
    else

      # Find latest mtime in local and server copy
      local_mtime=$(find /home/$local_user/$directory -printf "%Ts\n" | sort -g | tail -n 1)
      server_mtime=$($rsh "cat /home/$remote_user/sync.tim" || echo "0000000000")

      # Compare mtimes
      if [ "$local_mtime" -lt "$server_mtime" ]; then
        # Server copy is newer - download it
        sync_down
      elif [ "$local_mtime" -gt "$server_mtime" ]; then
        # Local copy is newer - upload it, then update server copy's timestamp on success
        sync_up && $rsh "echo $local_mtime > /home/$remote_user/sync.tim"
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

# Remove traps
trap - INT TERM EXIT

exit 0

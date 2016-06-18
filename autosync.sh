#!/bin/bash

#
# Tinysync - Simple tool for keeping a directory synchronized between multiple computers
# autosync.sh - automatically synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Depends: sync.sh, inotify-tools
# Version: 1.0
#
# To activate automatic syncing, run this script upon startup (e.g. via systemd service)
#

# Gather information about the environment
basedir=$(dirname "$0")
local_user=$(whoami)
date="/usr/bin/date -R"

load_config () {
  # Load configuration from file
  if [ ! -f "$basedir/sync.conf" ]; then
    echo "[`$date`] Config file not found: $basedir/sync.conf"
    echo "Please copy the sample config file and edit it accordingly"
    return 1
  fi

  source $basedir/sync.conf
}



###############################################################################
# Main starts here
###############################################################################

# Load configuration
if ! load_config; then
  exit 1
fi

$basedir/sync.sh

while true
do
	inotifywait -qqr $events /home/$local_user/$directory

	sleep $auto_wait

	$basedir/sync.sh
done

exit 0

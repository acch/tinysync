#!/bin/bash

#
# autosync.sh - automatically synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Depends: sync.sh, inotify-tools
# Version: 1.0
#
# To activate automatic snycing, run this script upon startup (gnome-session-properties)
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

su $local_user sh -c $basedir/sync.sh

while true
do
	inotifywait -qqr $events /home/$local_user/$directory

	sleep $auto_wait

	su $local_user sh -c $basedir/sync.sh
done

exit 0

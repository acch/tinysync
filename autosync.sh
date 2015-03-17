#!/bin/bash

#
# autosync.sh - automatically synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Depends: sync.sh, inotify-tools
#
# To activate automatic snycing, run this script upon startup (gnome-session-properties)
#

# -------------- Options --------------
directory="YOUR_DIRECTORY"
local_user="YOUR_USER"
script="/path/to/sync.sh"
events="-e close_write -e move -e delete"
wait=30
# -------------------------------------

#
# Main starts here
#

$script

while true
do
	inotifywait -qqr $events /home/$local_user/$directory
	
	sleep $wait

	$script
done

exit 0

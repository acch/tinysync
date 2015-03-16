#!/bin/bash

#
# autosync.sh - automatically synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Version: 1.0
# Depends: sync.sh, inotify-tools
#
# To activate automatic snycing, run this script upon startup (gnome-session-properties)
#

# -------------- Options --------------
homedir="/home/achim"
directory=".secret_encfs"
events="-e close_write -e move -e delete"
wait=30
script="$homedir/bin/sync.sh"
# -------------------------------------

#
# Main starts here
#

$script

while true
do
	inotifywait -qqr $events $homedir/$directory
	
	sleep $wait

	$script
done

exit 0

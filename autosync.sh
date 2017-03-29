#!/bin/bash

#
# Tinysync - Simple tool for keeping a directory synchronized between multiple computers
# autosync.sh - automatically synchronize folders between multiple clients via ssh/rsync
#
# Author: acch
# Depends: sync.sh, inotify-tools
# Version: 1.2
#
# To activate automatic syncing, run this script upon startup (e.g. via systemd service)
#

# Ignore linter errors
# shellcheck disable=SC2086
# shellcheck disable=SC2154

# Treat unset variables as an error
set -u

# Gather information about the environment
basedir=$(dirname "$0")
local_user=$(whoami)
date="/usr/bin/date -R"


# Sanity checks
if ! which inotifywait &> /dev/null; then
  echo "[$($date)] 'inotify-tools' not found - please install it!"
  exit 1
fi

if [ ! -x "$basedir/sync.sh" ]; then
  echo "[$($date)] Script not found: $basedir/sync.sh"
  echo "Please copy sync.sh and autosync.sh into the same directory!"
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
}


###############################################################################
# Main starts here
###############################################################################

# Load configuration
if ! load_config; then
  exit 1
fi

# Initial sync
$basedir/sync.sh

while true
do
  # Wait for events
  inotifywait -qqr $events /home/$local_user/$directory

  # Wait for a moment
  sleep $auto_wait

  # Sync changes
  $basedir/sync.sh
done

exit 0

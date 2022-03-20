#!/usr/bin/env bash

#
# Tinysync - Simple tool for keeping a directory synchronized between multiple computers
# install.sh - automatically install files to their designated locations
#

# Ignore linter errors
# shellcheck disable=SC2086

# Treat unset variables as an error
set -u

# Gather information about the environment
basedir=$(dirname "$0")
local_user=$(whoami)

# Sanity checks
if [ ! -f "$basedir/sync.sh" ] || [ ! -f "$basedir/autosync.sh" ] || [ ! -f "$basedir/sync.conf.sample" ] || [ ! -f "$basedir/sync.desktop" ] || [ ! -d "$basedir/systemd/" ]; then
  echo "Tinysync not found - ensure that you have properly downloaded and extracted all files!"
  exit 1
fi

echo "Installing Tinysync (will prompt for your password)..."

[ -f /usr/local/bin/sync.sh ] || sudo cp $basedir/sync.sh /usr/local/bin/
[ -x /usr/local/bin/sync.sh ] || sudo chmod a+x /usr/local/bin/sync.sh
[ -f /usr/local/bin/autosync.sh ] || sudo cp $basedir/autosync.sh /usr/local/bin/
[ -x /usr/local/bin/autosync.sh ] || sudo chmod a+x /usr/local/bin/autosync.sh
[ -f /usr/local/bin/sync.conf ] || sudo cp $basedir/sync.conf.sample /usr/local/bin/sync.conf
[ -f /var/log/sync.log ] || sudo touch /var/log/sync.log && sudo chown $local_user /var/log/sync.log

if [ -d "$HOME/.local/share/applications/" ]; then
  [ -f "$HOME/.local/share/applications/sync.desktop" ] || cp $basedir/sync.desktop $HOME/.local/share/applications/
fi

if [ -d /etc/systemd/ ]; then
  echo
  echo "Installing systemd units..."

  if [ ! -f /etc/systemd/system/sync@.service ]; then
    sudo cp $basedir/systemd/* /etc/systemd/system/
    sudo systemctl daemon-reload
  fi

  echo
  echo "...done!"
  echo
  echo "Please modify the configuration file /usr/local/bin/sync.conf according to your"
  echo "setup. Then, please manually run sync.sh to verify that your configuration"
  echo "parameters are correct. Once manual syncing of the directory works well you can"
  echo "enable automatic syncing with the following commands:"
  echo
  echo "sudo systemctl enable sync@${local_user}.timer"
  echo "sudo systemctl start sync@${local_user}.timer"
  echo "sudo systemctl enable autosync@${local_user}"
  echo "sudo systemctl start autosync@${local_user}"
  echo

  exit 0
fi

echo
echo "...done!"
echo
echo "This doesn't seem to be a systemd-based distribution - please refer to the"
echo "README.md for manual installation instructions."
echo

exit 0

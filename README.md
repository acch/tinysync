# Tinysync

Tinysync is a simple tool for keeping a directory synchronized between multiple computers.
Its primary design goal is to be small, lightweight, and not require additional software to accomplish this task.

Tinysync is based on [Bash](https://www.gnu.org/software/bash/) and [rsync](https://rsync.samba.org/) - it is known to run on Linux and FreeBSD, but should work on any Unix-compatible operating system.
The tool requires a central server to synchronize data with, but in fact does not require installation of any software on this server.

---

### What it is designed for:
- A single user, working on different computers during different times of the day

### What it is *not* designed for:
- A single user, working on different computers simultaneously
- Multiple users sharing files with each other

### Important
Tinysync does not implement logic for locking files or resolving conflicts. If files are modified on different clients simultaneously then some of these changes will get lost!

---

## Components

File | Description
--- | ---
sync.conf.sample | Sample configuration file which needs to be copied and modified according to your setup
*sync.conf* | The configuration file which includes information about your setup, such as server address and user name
sync.sh | The main executable script which synchronizes the directory with the server
sync.desktop | Optional desktop entry which can be used to manually run `sync.sh`
autosync.sh | Optional executable script which will enable automatic synchronization when the directory is modified
autosync.desktop | Optional desktop entry which can be used to automatically run `autosync.sh` upon startup


## Installation

1. Download the software to a client, extract the archive (if applicable), and place the files in a directory of your choice.

2. Copy the sample configuration file and modify it according to your setup:

       cp sync.conf.sample sync.conf
       vi sync.conf

3. Tinysync relies on SSH Public-Key Authentication (a.k.a. Password-less logins) to be set up so that a client can connect to the server without being prompted for a password.
   Ensure that `rsync` is installed on both, client and server.

4. Manually run `sync.sh` from a terminal to verify that your configuration parameters are correct. When connecting to a server for the first time, ensure that the directory does *not* exist on the server (it will be uploaded). When adding more clients, ensure that the directory does *not* exist on the client (it will be downloaded).

5. In a typical usage scenario you should run `sync.sh` repeatedly, e.g. via cron. Add something like the following to your crontab (`crontab -e`) to enable scheduled synchronization:

       */10 * * * * /path/to/sync.sh &>> /var/log/sync.err

6. In addition to scheduled replication, you can manually run `sync.sh` to synchronize the directory with the server. Copy the `sync.desktop` file to the folder `~/.local/share/applications/` to add an appropriate menu entry. Edit the desktop entry so that is contains the appropriate path to `sync.sh`:

       Exec=/path/to/sync.sh

7. You can also enable automatic synchronization using `autosync.sh`.
   It requires the installation of [inotify-tools](http://wiki.github.com/rvoicilas/inotify-tools/), as well as an inotify-compatible filesystem.

   Note that automatic synchronization using `autosync.sh` is optional. Even if you enable automatic synchronization you should still configure scheduled replication (via cron) in addition to that.

   To enable automatic synchronization, run `autosync.sh` upon startup. There are numerous mechanisms you can use:

   ### Gnome Desktop

   For Gnome on Linux copy the `autosync.desktop` file to the folder `~/.config/autostart/`. Edit the desktop entry so that is contains the appropriate path to `autosync.sh`:

       Exec=/path/to/autosync.sh

   ### KDE Desktop

   For KDE on Linux create a symbolic link to `autosync.sh` in the folder `~/.kde/Autostart/`.

   ### Systemd

   Coming soon...

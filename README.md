# Tinysync

Tinysync is a simple tool for keeping a directory synchronized between multiple computer systems.
Its primary design goal is to be small, lightweight, and not require additional software to accomplish this task.

Tinysync is based on [Bash](https://www.gnu.org/software/bash/) and [rsync](https://rsync.samba.org/) - it is known to run on Linux and BSD, but should work on any Unix-compatible operating system.
Tinysync requires a central server to synchronize data with, but in fact does not require installation of any software on this server.

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

- **_ sync.conf _**
  The configuration file which includes your personal information such as server address and user name
- **sync.conf.sample**
  Sample configuration file which which needs to be copied and edited
- **sync.sh**
  The main executable script which synchronizes the directory with the server
- **sync.desktop**
  Optional desktop entry which can be used to manually run `sync.sh`
- **autosync.sh**
  Optional executable script which will enable automatic synchronization when something in the directory changes
- **autosync.desktop**
  Optional desktop entry which can be used to automatically run `autosync.sh` upon startup


## Installation

1. Download Tinysync to a client, extract the archive (if applicable), and place the files in a directory of your choice.

2. Copy the sample configuration file and modify it according to your setup

   ```
   cp sync.conf.sample sync.conf
   vi sync.conf
   ```

3. Tinysync relies on SSH Public-Key Authentication (a.k.a. Password-less logins) to be set up so that a client can connect to the server without being prompted for a password.
   Ensure that rsync is installed on both, client and server.

4. In a typical usage scenario you should run `sync.sh` repeatedly, e.g. via cron. Add something like the following to your crontab (`crontab -e`) to enable scheduled synchronization:

   ```
   */10 * * * * /path/to/sync.sh &>> /var/log/sync.err
   ```

5. You can also enable automatic synchronization using `autosync.sh`.
   It requires the installation of [inotify-tools](http://wiki.github.com/rvoicilas/inotify-tools/), as well as an inotify-compatible filesystem.

   Note that automatic synchronization using `autosync.sh` is optional. Even if you enable automatic synchronization you should still configure scheduled replication (via cron) in addition to that.

   To enable automatic synchronization, run `autosync.sh` upon startup. There are numerous mechanisms you can use:

   ### Gnome Desktop

   For Gnome on Linux copy the `autosync.desktop` file to the folder `~/.config/autostart/`.

   ### KDE Desktop

   For KDE on Linux create a symbolic link to `autosync.sh` in the folder `~/.kde/Autostart/`.

   ### Systemd

   Coming soon...

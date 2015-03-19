# Tinysync

Tinysync is a simple tool for keeping a directory synchronized between different computers.
Its primary design goal is to be small, lightweight, and not require any additional software to accomplish this task.

Tinysync is based on [Bash](https://www.gnu.org/software/bash/) and [rsync](https://rsync.samba.org/) - it is known to run on Linux and BSD, but should work on any Unix-compatible operating system.
Tinysync requires a central server to synchronize data with, but in fact does not require installation of any software on this server.

## Components

- **_sync.conf_**
  The configuration file which includes your personal information such as server address and user name
- **sync.conf.sample**
  Sample configuration file which which needs to be copied and edited
- **sync.sh**
  The main executable script which synchronizes the directory with the server
- **sync.desktop**
  Optional desktop entry which can be used to manually run `sync.sh`
- **autosync.sh**
  An optional script which will enable automatic synchronization when something in the directory changes
- **autosync.desktop**
  Optional desktop entry which can be used to automatically run the `autosync.sh` script upon startup


## Installation

Tinysync requires SSH Public-Key Authentication (a.k.a. Password-less logins) to be set up so that a client can connect to the server without being prompted for a password.

Tinysync runs on the client. The server needs to accept SSH connections, only.

In a typical scenario you will need to run `sync.sh` repeatedly, e.g. via cron. You should add something like the following to your crontab (`crontab -e`):

```
*/10 * * * * /path/to/sync.sh &>> /var/log/sync.err
```

This will enable scheduled synchronization. You can also enable automatic synchronization using the `autosync.sh` script. It requires the installation of [inotify-tools](http://wiki.github.com/rvoicilas/inotify-tools/), as well as an inotify-compatible filesystem.

Note that automatic synchronization using the `autosync.sh` script is optional. Even if you enable automatic synchronization it is still recommended to configure scheduled replication (via cron) in addition to that.

To enable automatic synchronization, you should run `autosync.desktop` automatically upon startup. There are numerous mechanisms you can use:

### Gnome Desktop

For Gnome on Linux you should copy the `autosync.desktop` file to the folder `~/.config/autostart/`

### KDE Desktop

For KDE on Linux you should create a symbolic link to `autosync.sh` in the folder `~/.kde/Autostart/`

### Systemd

Coming soon...

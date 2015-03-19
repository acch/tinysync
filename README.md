# tinysync

Tinysync is a simple tool for keeping a directory synchronized between different computers.
Its primary design goal is to be small, lightweight, and to not require any additional software for accomplishing this task.
Tinysync requires a central server to synchronize data to and from, but in fact does not require installation of any software on this server.

## Components

- **_sync.conf_**
  The configuration file which includes personal information such as network addresses and user names
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

Typically you will want to run `sync.sh` repeatedly, e.g. via cron. You should add something like the following to your crontab (`crontab -e`):

```
*/10 * * * * /path/to/sync.sh &>> /var/log/sync.err
```

### Gnome Desktop

For Gnome on Linux you should copy the `autosync.desktop` file to the folder `~/.config/autostart/`

### KDE Desktop

For KDE on Linux you should create a symbolic link to `autosync.sh` in the folder `~/.kde/Autostart/`

### Systemd

Coming soon...

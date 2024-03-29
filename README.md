# Tinysync

[![GitHub Workflow](https://img.shields.io/github/actions/workflow/status/acch/tinysync/main.yml?branch=master)](https://github.com/acch/tinysync/actions) [![GitHub Issues](https://img.shields.io/github/issues/acch/tinysync.svg)](https://github.com/acch/tinysync/issues) [![GitHub Stars](https://img.shields.io/github/stars/acch/tinysync.svg?label=github%20%E2%98%85)](https://github.com/acch/tinysync/stargazers) [![Docker Pulls](https://img.shields.io/docker/pulls/acch/tinysync.svg)](https://hub.docker.com/r/acch/tinysync/) [![License](https://img.shields.io/github/license/acch/tinysync.svg)](LICENSE)

Tinysync is a simple tool for keeping a directory synchronized between multiple computers.
Its primary design goal is to be small, lightweight, and not to require additional software to accomplish this task.

Tinysync is based on [Bash](https://www.gnu.org/software/bash/) and [rsync](https://rsync.samba.org/) — it is known to run on Linux and FreeBSD, but should work on any Unix-compatible operating system.
The tool requires a central server to synchronize data with, but in fact does not require installation of any software on this server. The required packages are typically installed as part of the base operating system.

* * *

### What it is designed for:

-   A single user, working on different computers during different times of the day

### What it is _not_ designed for:

-   A single user, working on different computers simultaneously
-   Multiple users sharing files with each other

### Important

Tinysync does not implement logic for locking files or resolving conflicts. If files are modified on different clients simultaneously then some of these changes will get lost!

* * *

## Components

| File                                       | Description                                                                                              |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------- |
| sync.conf.sample                           | Sample configuration file which needs to be copied and modified according to your setup                  |
| _sync.conf_                                | The configuration file which includes information about your setup, such as server address and user name |
| sync.sh                                    | The main executable script which synchronizes the directory with the server                              |
| systemd/sync@.service, systemd/sync@.timer | Optional systemd timer which can be used to periodically run `sync.sh`                                   |
| sync.desktop                               | Optional desktop entry which can be used to manually run `sync.sh`                                       |
| autosync.sh                                | Optional executable script which will enable automatic synchronization when the directory is modified    |
| systemd/autosync@.service                  | Optional systemd service which can be used to automatically run `autosync.sh` upon startup               |
| autosync.desktop                           | Optional desktop entry which can be used to automatically run `autosync.sh` upon startup                 |

* * *

## Server

### Docker deployment

The preferred method for setting up the Tinysync server is by running a container from the pre-built [Docker](https://www.docker.com) image [acch/tinysync](https://hub.docker.com/r/acch/tinysync). You will need to supply your public SSH key when running the container.

Using plain [Docker](https://docs.docker.com/engine/reference/run):

    docker run --rm \
      --name tinysync \
      -p 2222:22 \
      -v tinysync_ssh:/etc/ssh \
      -v tinysync_data:/home/tinysync \
      -e AUTHORIZED_KEYS="$(cat ~/.ssh/id_rsa_tinysync.pub)" \
      acch/tinysync

Using [Docker-Compose](https://docs.docker.com/compose/compose-file):

    version: '2'

    services:
      tinysync:
        image: acch/tinysync
        container_name: tinysync
        ports:
          - "2222:22"
        volumes:
          - ssh:/etc/ssh
          - data:/home/tinysync
        environment:
          - AUTHORIZED_KEYS=...
        restart: always

    volumes:
      ssh:
        driver: local
      data:
        driver: local

Note that the Docker image has a pre-defined (fixed) user named _tinysync_. The actual data volume should always be mounted to `/home/tinysync`.

### Manual server installation

To manually install the Tinysync server component ensure that you have `openssh` and `rsync` installed on that system.

Tinysync relies on SSH Public-Key Authentication (a.k.a. password-less logins) to be set up so that a client can connect to the server without being prompted for a password. Ensure that SSH Public-Key Authentication is enabled on your server:

    /etc/ssh/sshd_config:
      ...
      PubkeyAuthentication yes
      ...

In addition, you will need to add your public SSH key to the file `~/.ssh/authorized_keys` on your server. The easiest way to achieve this is by running the following command from one of your clients:

    ssh-copy-id -i ~/.ssh/id_rsa_tinysync.pub REMOTE_USER@YOUR_SERVER

## Clients

### Automatic client installation

The preferred method for installing Tinysync on clients is by using the `install.sh` script. Alternatively, you can follow the [Manual Installation](#manual-installation) procedure below.

1.  There are several options for downloading the software:

    -   Download the latest [release](https://github.com/acch/tinysync/releases/latest)
    -   Clone the repo: `git clone https://github.com/acch/tinysync.git`

    Download the software to a client, extract the archive (if applicable), and run the automatic installer script:

        tinysync/install.sh

2.  Modify the sample configuration according to your setup:

        vi /usr/local/bin/sync.conf

3.  Manually run `sync.sh` from a terminal to verify that your configuration parameters are correct. When connecting to a server for the first time, ensure that the directory does **not** exist on the server (it will be uploaded). When adding more clients later, ensure that the directory does **not** exist on the client (it will be downloaded).

4.  Once manual synchronization of the directory works well you can enable automatic synchronization for your user account with the following commands :

        sudo systemctl enable sync@YOUR_USER.timer
        sudo systemctl start sync@YOUR_USER.timer
        sudo systemctl enable autosync@YOUR_USER
        sudo systemctl start autosync@YOUR_USER

### Manual client installation

1.  Download the software to a client, extract the archive (if applicable), and place the executable files and configuration sample in a directory of your choice (such as `/usr/local/bin`).

        git clone https://github.com/acch/tinysync.git
        cp tinysync/sync.sh tinysync/autosync.sh tinysync/*.sample /usr/local/bin/

2.  Copy the sample configuration file and modify it according to your setup:

        cd /usr/local/bin
        cp sync.conf.sample sync.conf
        vi sync.conf

3.  Tinysync relies on SSH Public-Key Authentication (a.k.a. password-less logins) to be set up so that a client can connect to the server without being prompted for a password. Ensure that `rsync` is installed on both, client and server.

4.  Manually run `sync.sh` from a terminal to verify that your configuration parameters are correct. When connecting to a server for the first time, ensure that the directory does **not** exist on the server (it will be uploaded). When adding more clients later, ensure that the directory does **not** exist on the client (it will be downloaded).

5.  In a typical usage scenario you will want to repeatedly synchronize the directory, e.g. via cron. Add something like the following to your crontab (`crontab -e`) to enable scheduled synchronization:

        */10 * * * * /usr/local/bin/sync.sh &>> /var/log/sync.err

    Alternatively, you can use [systemd timers](https://www.freedesktop.org/software/systemd/man/systemd.timer.html) to periodically synchronize the directory on systemd-based distributions. Simply copy the `systemd/sync@.service` and `systemd/sync@.timer` files to the folder `/etc/systemd/system` and enable it for your user account:

        sudo systemctl daemon-reload
        sudo systemctl enable sync@YOUR_USER.timer
        sudo systemctl start sync@YOUR_USER.timer

6.  In addition to scheduled replication, you can manually run `sync.sh` to synchronize the directory with the server. Copy the `sync.desktop` file to the folder `~/.local/share/applications/` to add an appropriate menu entry. You may need to edit the desktop entry so that is contains the appropriate path to `sync.sh`:

        ...
        Exec=/usr/local/bin/sync.sh
        ...

7.  You can also enable automatic synchronization using `autosync.sh`.
    It requires the installation of [inotify-tools](http://wiki.github.com/rvoicilas/inotify-tools/), as well as an inotify-compatible filesystem.

    Note that automatic synchronization using `autosync.sh` is optional. Even if you enable automatic synchronization you should still configure scheduled replication (via cron or systemd) in addition to that.

    To enable automatic synchronization, run `autosync.sh` upon startup. There are numerous mechanisms you can use:

    ### Systemd

    The preferred way of running `autosync.sh` is via [systemd](https://www.freedesktop.org/wiki/Software/systemd/). In addition to enabling automatic synchronization, the systemd service will delay system shutdown so that a running synchronization is not interrupted.

    For systemd-based distributions copy the `systemd/autosync@.service` file to the folder `/etc/systemd/system` and enable it for your user account:

        sudo systemctl daemon-reload
        sudo systemctl enable autosync@YOUR_USER
        sudo systemctl start autosync@YOUR_USER

    ### Gnome Desktop

    For Gnome on Linux copy the `autosync.desktop` file to the folder `~/.config/autostart/`. You may need to edit the desktop entry so that is contains the appropriate path to `autosync.sh`:

        ...
        Exec=/usr/local/bin/autosync.sh
        ...

    ### KDE Desktop

    For KDE on Linux create a symbolic link to `autosync.sh` in the folder `~/.kde/Autostart/`.

## Frequently asked questions

**Q:** Automatic synchronization doesn't work, what can I do?

**A:** First of all, ensure that you have the `inotifywait` binary installed. On most distributions it is provided by a package _inotify-tools_.

If `inotifywait` is indeed installed but you are attempting to synchronize a large directory you may need to adapt the kernel parameter _fs.inotify.max_user_watches_. In such case you will encounter the following error message when trying to run `autosync.sh`:

    Failed to watch ...; upper limit on inotify watches reached!
    Please increase the amount of inotify watches allowed per user via `/proc/sys/fs/inotify/max_user_watches'.

To increase the amount of inotify watches, simply create a new file `/etc/sysctl.d/inotify.conf`:

    fs.inotify.max_user_watches = 16384

## Copyright and license

Copyright Achim Christ, released under the [MIT license](LICENSE).

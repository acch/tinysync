FROM alpine:3.7
MAINTAINER Achim Christ

# Install prerequisites
RUN apk add --no-cache \
  openssh \
  rsync

# Create named user
RUN adduser -D -s /bin/ash tinysync \
&& passwd -u tinysync \
&& mkdir /data \
&& chown tinysync:tinysync /data \
&& ln -s /data /home/tinysync/data

# Prepare SSH config
RUN mkdir /home/tinysync/.ssh \
&& chmod 700 /home/tinysync/.ssh \
&& touch /home/tinysync/.ssh/authorized_keys \
&& chmod 600 /home/tinysync/.ssh/authorized_keys \
&& chown -R tinysync:tinysync /home/tinysync/.ssh \
&& sed -i 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config \
&& sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Default environment
ENV AUTHORIZED_KEYS none

# Copy run-time script
COPY entrypoint.sh /

# Expose volumes
VOLUME ["/etc/ssh", "/data"]

# Expose ports
EXPOSE 22

# Declare SSH daemon as entrypoint
ENTRYPOINT ["/entrypoint.sh"]
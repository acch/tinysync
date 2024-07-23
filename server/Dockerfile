FROM docker.io/alpine:3.19.3

# Install prerequisites
# hadolint ignore=DL3018
RUN apk add --no-cache \
  openssh \
  rsync

# Create named user
RUN adduser -D -s /bin/ash tinysync \
&& passwd -u tinysync

# Prepare SSH config
RUN mkdir /home/tinysync/.ssh \
&& chmod 700 /home/tinysync/.ssh \
&& touch /home/tinysync/.ssh/authorized_keys \
&& chmod 600 /home/tinysync/.ssh/authorized_keys \
&& chown -R tinysync:tinysync /home/tinysync/.ssh \
&& sed -e 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' \
       -e 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/' \
       -e 's/^#PermitRootLogin.*$/PermitRootLogin no/' -i /etc/ssh/sshd_config

# Default environment
ENV AUTHORIZED_KEYS none

# Copy run-time script
COPY entrypoint.sh /

# Expose volumes
VOLUME ["/etc/ssh", "/home/tinysync"]

# Expose ports
EXPOSE 22

# Declare SSH daemon as entrypoint
ENTRYPOINT ["/entrypoint.sh"]

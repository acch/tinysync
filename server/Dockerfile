FROM alpine:3.7
MAINTAINER Achim Christ

# Install prerequisites
RUN apk add --no-cache \
  openssh \
  rsync

# Prepare SSH config
RUN mkdir /root/.ssh \
&& chmod 700 /root/.ssh \
&& touch /root/.ssh/authorized_keys \
&& chmod 600 /root/.ssh/authorized_keys \
&& sed -i 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config \
&& sed -i 's/^#PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Default environment
ENV AUTHORIZED_KEYS none

# Copy run-time script
COPY entrypoint.sh /

# Expose volumes
VOLUME ["/etc/ssh", "/root/data"]

# Expose ports
EXPOSE 22

# Declare SSH daemon as entrypoint
ENTRYPOINT ["/entrypoint.sh"]

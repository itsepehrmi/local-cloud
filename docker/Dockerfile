FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install SSH server, Nginx, Python, and basic tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    nginx \
    sudo \
    curl \
    vim \
    net-tools \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create the deploy user
RUN useradd -m -s /bin/bash deploy \
    && echo "deploy:deploy" | chpasswd \
    && usermod -aG sudo deploy \
    && echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup SSH
RUN mkdir -p /var/run/sshd

# Copy public key for the deploy user
COPY ssh/id_ec2.pub /tmp/id_ec2.pub
RUN mkdir -p /home/deploy/.ssh \
    && cat /tmp/id_ec2.pub > /home/deploy/.ssh/authorized_keys \
    && chown -R deploy:deploy /home/deploy/.ssh \
    && chmod 700 /home/deploy/.ssh \
    && chmod 600 /home/deploy/.ssh/authorized_keys \
    && rm /tmp/id_ec2.pub

# Create app directory
RUN mkdir -p /opt/myapp /var/log/myapp \
    && chown -R deploy:deploy /opt/myapp /var/log/myapp

# Copy entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
EXPOSE 22 80

# Start everything via entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

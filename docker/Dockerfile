FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app


COPY app/requirements.txt .
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update && apt-get install -y \
    openssh-server \
    nginx \
    sudo \
    python3 \
    curl \
    && rm -rf /var/lib/apt/lists/*


RUN useradd -m -s /bin/bash deploy \
    && echo "deploy:deploy" | chpasswd \
    && usermod -aG sudo deploy \
    && echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


RUN mkdir -p /var/run/sshd
COPY ssh/id_ec2.pub /tmp/id_ec2.pub
RUN mkdir -p /home/deploy/.ssh \
    && cat /tmp/id_ec2.pub > /home/deploy/.ssh/authorized_keys \
    && chown -R deploy:deploy /home/deploy/.ssh \
    && chmod 700 /home/deploy/.ssh \
    && chmod 600 /home/deploy/.ssh/authorized_keys \
    && rm /tmp/id_ec2.pub


RUN mkdir -p /opt/myapp /var/log/myapp \
    && chown -R deploy:deploy /opt/myapp /var/log/myapp


COPY --from=builder /opt/venv /opt/venv


COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


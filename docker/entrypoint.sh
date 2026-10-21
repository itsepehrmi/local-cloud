#!/bin/bash
#
# entrypoint.sh - Start all services inside the container
#

set -e

echo "=========================================="
echo " Starting Local EC2 container"
echo "=========================================="

echo "[1/4] Starting SSH daemon..."
mkdir -p /var/run/sshd
/usr/sbin/sshd
echo " SSH started OK"

echo "[2/4] Python venv is ready."
echo "[2/4] Python venv is ready (built in Dockerfile)."
echo "[3/4] Configuring Nginx..."
if [ -f /tmp/nginx-myapp.conf ]; then
    cp /tmp/nginx-myapp.conf /etc/nginx/sites-available/myapp
    ln -sf /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
    rm -f /etc/nginx/sites-enabled/default
    echo " Nginx config copied"
else
    echo " WARNING: /tmp/nginx-myapp.conf not found"
fi
nginx
echo " Nginx started OK"

echo "[4/4] Starting gunicorn..."
echo ""
echo "========================================"
echo " ALL services started!"
echo "========================================"
cd /opt/myapp
exec opt/venv/bin/gunicorn \
    --workers 2 \
    --bind 127.0.0.1:5000 \
    --access-logfile - \
    --error-logfile - \
    app:app


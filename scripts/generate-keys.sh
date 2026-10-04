#!/bin/bash
#
# generate-keys.sh - Generate SSH key pair for local-cloud project
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_DIR="$(dirname "$SCRIPT_DIR")/ssh"
KEY_FILE="$SSH_DIR/id_ec2"

if [ -f "$KEY_FILE" ]; then
    echo "Key already exists: $KEY_FILE"
    echo "Delete it first if you want to regenerate."
    exit 1
fi

echo "Generating SSH key pair..."
ssh-keygen -t ed25519 -f "$KEY_FILE" -N "" -C "local-cloud"

echo ""
echo "Done! Files created:"
echo " Private: $KEY_FILE"
echo " Public: $KEY_FILE.pub"

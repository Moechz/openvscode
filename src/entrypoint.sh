#!/bin/sh
# ===========================================================================
# OpenVSCode Server entrypoint for a non-root container (TOS 7 requirement).
#
# The upstream image starts the editor with --without-connection-token, which
# means anyone who can reach the port gets a terminal on the NAS. This wrapper
# generates a random connection token on the first start, stores it in the
# workspace and passes it with --connection-token-file; the full URL is printed
# in the container log.
# ===========================================================================
set -e
set -u

WS=/home/workspace
TOKEN_FILE="$WS/.connection-token"
SERVER=/home/.openvscode-server/bin/openvscode-server

mkdir -p "$WS" 2>/dev/null || true

if [ -s "$TOKEN_FILE" ]; then
  TOKEN=$(cat "$TOKEN_FILE")
else
  TOKEN=$(head -c 32 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 24)
  printf '%s' "$TOKEN" > "$TOKEN_FILE"
  chmod 600 "$TOKEN_FILE" 2>/dev/null || true
fi

echo "==============================================================="
echo " OpenVSCode: open http://<NAS-IP>:<host-port>/?tkn=${TOKEN}"
echo " (token also stored in workspace/.connection-token)"
echo "==============================================================="

exec "$SERVER" --host 0.0.0.0 --connection-token-file "$TOKEN_FILE"

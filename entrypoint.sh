#!/bin/sh
set -euo pipefail

echo "Starting container at $(date)"

if [ -z "${RTORRENT_RPC:-}" ]; then
  echo "RTORRENT_RPC not set" >&2
  exit 1
fi

if [ -z "${RADARR_URL:-}" ]; then
  echo "RADARR_URL not set" >&2
  exit 1
fi

if [ -z "${RADARR_API_KEY:-}" ]; then
  echo "RADARR_API_KEY not set" >&2
  exit 1
fi

# Export RTORRENT_RPC to a file that cronjob can source
echo "export RTORRENT_RPC=\"${RTORRENT_RPC}\"" > /run/container.env
echo "export RADARR_URL=\"${RADARR_URL}\"" >> /run/container.env
echo "export RADARR_API_KEY=\"${RADARR_API_KEY}\"" >> /run/container.env
chmod 600 /run/container.env

echo "Welcome to TinyTrumparr!"
echo "Starting cron daemon"

exec cron -f

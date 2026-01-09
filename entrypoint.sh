#!/bin/sh
set -u

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

echo "Welcome to TinyTrumparr!"
echo "Starting search for trumped movies with interval: ${SLEEP} seconds"

while true; do
  sleep $SLEEP
  /usr/local/bin/trump_search.sh
done

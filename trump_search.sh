#!/bin/sh

set -u

echo "Starting search at $(date)"

#loop through rtcontrol results for messages containing "Trump" and the "radarr" label and is complete
for h in $(rtcontrol -U "$RTORRENT_RPC" -q 'message=*Trump*' 'label=radarr' is_complete=y -o hash); do
    echo "Processing hash: $h"
    curl -s -H "X-Api-Key: $RADARR_API_KEY" "$RADARR_URL/api/v3/history?downloadId=$h" \
    | jq -r '.records[]? | "\(.data.fileId // "") \(.movieId // "")"' \
    | while read -r fileId movieId; do
        [ -n "$fileId" ] \
        && curl -s -X DELETE -H "X-Api-Key: $RADARR_API_KEY" "$RADARR_URL/api/v3/moviefile/$fileId" \
        && echo "Deleted moviefile with ID: $fileId"
        [ -n "$movieId" ] \
        && curl -s -X POST -H "X-Api-Key: $RADARR_API_KEY" -H "Content-Type: application/json" -d "{\"name\":\"MoviesSearch\",\"movieIds\":[$movieId]}" "$RADARR_URL/api/v3/command" \
        && echo "Triggered MoviesSearch for movie ID: $movieId"
        done
    #delete the torrent and its data from rtorrent
    rtcontrol -U "$RTORRENT_RPC" -q "hash=$h" --cull \
    && echo "Deleted torrent with hash: $h"
done

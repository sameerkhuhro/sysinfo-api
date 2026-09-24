#!/bin/bash

LOG_FILE="/var/log/nginx/sysinfo-api.access.log"
ARCHIVE_DIR="/var/log/nginx/archives"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVED_FILE="${ARCHIVE_DIR}/access_${TIMESTAMP}.log.gz"

mkdir -p "$ARCHIVE_DIR"

if [[ ! -s "$LOG_FILE" ]]; then
    echo "$(date): Log file is empty or missing. Skipping." \
        | tee -a /var/log/archive_logs.log
    exit 0
fi

gzip -c "$LOG_FILE" > "$ARCHIVED_FILE"

if [[ $? -eq 0 ]]; then
    > "$LOG_FILE"
    echo "$(date): Archived to $ARCHIVED_FILE" \
        | tee -a /var/log/archive_logs.log
else
    echo "$(date): ERROR — archiving failed." \
        | tee -a /var/log/archive_logs.log
    exit 1
fi

find "$ARCHIVE_DIR" -name "*.log.gz" -mtime +30 -delete

echo "$(date): Cleanup complete." \
    | tee -a /var/log/archive_logs.log

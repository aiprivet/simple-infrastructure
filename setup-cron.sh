#!/bin/bash
set -euo pipefail


TEMP_CRON=$(mktemp)

crontab -l 2>/dev/null | grep -v "auto-update.sh" > "$TEMP_CRON" || true

echo "*/1 * * * * ~/infrastructure/auto-update.sh >> ~/infrastructure/auto-update.log 2>&1" >> "$TEMP_CRON"

crontab "$TEMP_CRON"

rm "$TEMP_CRON"

echo "Cron job configured successfully!"
echo "Script will run every 5 seconds"
echo "Logs will be saved in: ~/infrastructure/auto-update.log"
echo ""
echo "To view current cron jobs execute: crontab -l"
echo "To remove cron job execute: crontab -e (and remove the line with auto-update.sh)"

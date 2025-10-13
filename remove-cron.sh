#!/bin/bash
set -euo pipefail

# Скрипт для удаления cron job автоматического обновления

echo "Removing cron job for automatic update..."

# Создаем временный файл для cron job
TEMP_CRON=$(mktemp)

# Получаем текущие cron jobs (исключая наши)
crontab -l 2>/dev/null | grep -v "auto-update.sh" > "$TEMP_CRON" || true

# Устанавливаем новый crontab без нашей задачи
crontab "$TEMP_CRON"

# Удаляем временный файл
rm "$TEMP_CRON"

echo "Cron job removed successfully!"
echo "To check: crontab -l"

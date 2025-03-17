#!/bin/bash

PROCESS_NAME="sleep"
LOG_FILE="/var/log/monitoring.log"
STATUS_FILE="/tmp/process_monitor_status"
URL="https://test.com/monitoring/test/api"

# Получаем PID процесса
PID=$(pgrep -x "$PROCESS_NAME")

# Если процесс не запущен — ничего не делаем
if [[ -z "$PID" ]]; then
    exit 0
fi

# Проверяем, был ли процесс перезапущен
LAST_PID=$(cat "$STATUS_FILE" 2>/dev/null)
if [[ "$PID" != "$LAST_PID" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Процесс $PROCESS_NAME был перезапущен" >> "$LOG_FILE"
fi

echo "$PID" > "$STATUS_FILE"

# Отправляем HTTP-запрос
if ! curl -s -o /dev/null --connect-timeout 5 "$URL"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Ошибка: Сервер мониторинга недоступен" >> "$LOG_FILE"
fi

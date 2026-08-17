#!/usr/bin/env bash

# Путь к каталогу приложения и файлу журнала.
APP_DIR="/opt/app"
LOG_FILE="${APP_DIR}/log.txt"

# Набор символов, из которых будут составляться случайные строки.
CHARACTERS="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

# Создаём каталог приложения, если его ещё нет.
mkdir -p "$APP_DIR"

# Создаём файл журнала, если он отсутствует.
touch "$LOG_FILE"

# Генерируем случайную строку длиной от 1 до 20 символов.
generate_random_string() {
    local length
    local result=""

    length=$((RANDOM % 20 + 1))

    while [ "${#result}" -lt "$length" ]; do
        result="${result}${CHARACTERS:RANDOM % ${#CHARACTERS}:1}"
    done

    printf '%s\n' "$result"
}

# Продолжаем работу до остановки systemd-службы.
while true; do
    generate_random_string >> "$LOG_FILE"
    sleep 17s
done


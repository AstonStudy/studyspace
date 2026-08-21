#!/usr/bin/env bash
# Настраивает Nginx для локального сайта app.local.
# Запуск: sudo ./setup_app_local.sh

set -e

# Скрипту нужны права root, так как он меняет /etc и устанавливает пакеты.
if [ "$(id -u)" -ne 0 ]; then
    echo "Запустите скрипт с sudo: sudo ./setup_app_local.sh"
    exit 1
fi

# Установка программ, необходимых для сайта и Python-скрипта проверки.
apt-get update
apt-get install -y nginx openssl curl ca-certificates python3

# Добавляем локальное доменное имя, только если такой записи ещё нет.
if ! grep -q "app.local" /etc/hosts; then
    echo "127.0.0.1 app.local" >> /etc/hosts
fi

# Копируем тестовую страницу в папку, из которой Nginx отдаёт сайт.
mkdir -p /var/www/app.local
cp site/index.html /var/www/app.local/index.html

# Создаём сертификат только при первом запуске.
mkdir -p /etc/nginx/ssl
if [ ! -f /etc/nginx/ssl/app.local.crt ]; then
    openssl req -x509 -newkey rsa:2048 -sha256 -nodes -days 365 \
        -keyout /etc/nginx/ssl/app.local.key \
        -out /etc/nginx/ssl/app.local.crt \
        -subj "/CN=app.local" \
        -addext "subjectAltName=DNS:app.local"
fi

# Добавляем self-signed сертификат в доверенные на этой машине.
cp /etc/nginx/ssl/app.local.crt /usr/local/share/ca-certificates/app.local.crt
update-ca-certificates

# Включаем подготовленную конфигурацию виртуального хоста Nginx.
cp nginx/app.local.conf /etc/nginx/sites-available/app.local
ln -sf /etc/nginx/sites-available/app.local /etc/nginx/sites-enabled/app.local

# Проверяем конфигурацию и запускаем Nginx.
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "Готово. Откройте https://app.local/ или запустите ./check_resource.py https://app.local/"

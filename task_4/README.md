# Локальный сайт `app.local` с Nginx и HTTPS

Проект настраивает локальный сайт `app.local` в Nginx, подключает к нему self-signed HTTPS-сертификат и содержит Python-скрипт для проверки доступности HTTP(S)-ресурсов.

## Структура проекта

| Файл | Назначение |
| --- | --- |
| `setup_app_local.sh` | Устанавливает Nginx и настраивает локальный сайт на Debian/Ubuntu. |
| `nginx/app.local.conf` | Конфигурация виртуального хоста `app.local`. |
| `check_resource.py` | Проверяет сетевую доступность HTTP(S)-адреса. |
| `site/index.html` | Стартовая страница локального сайта. |

## Требования

- Debian/Ubuntu с пакетным менеджером `apt-get`;
- права `sudo`;
- доступ к репозиториям пакетов при первой установке.

## Настройка

```bash
chmod +x setup_app_local.sh check_resource.py
sudo ./setup_app_local.sh
```

Скрипт `setup_app_local.sh`:

- устанавливает `nginx`, `openssl`, `curl`, `ca-certificates` и `python3`;
- добавляет запись `127.0.0.1 app.local` в `/etc/hosts`, если её ещё нет;
- размещает страницу сайта в `/var/www/app.local`;
- создаёт сертификат `/etc/nginx/ssl/app.local.crt` и закрытый ключ `/etc/nginx/ssl/app.local.key`;
- добавляет сертификат в локальное хранилище доверенных сертификатов;
- включает конфигурацию Nginx для `app.local` и перезапускает сервис.

## Конфигурация Nginx

Файл `nginx/app.local.conf` копируется в `/etc/nginx/sites-available/app.local` и подключается через `/etc/nginx/sites-enabled/app.local`.

- Сервер на порту `80` перенаправляет запросы с `http://app.local` на HTTPS.
- Сервер на порту `443` использует self-signed сертификат и отдаёт файлы из `/var/www/app.local`.

## Как проверял

Общий вид команды:

```bash
./check_resource.py [--timeout СЕКУНДЫ] [--ca-cert ФАЙЛ] [-k] URL
```

Примеры:

```bash
./check_resource.py http://app.local/
./check_resource.py https://app.local/
./check_resource.py --ca-cert /etc/nginx/ssl/app.local.crt https://app.local/
```



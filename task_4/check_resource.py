#!/usr/bin/env python3
"""Проверяет сетевую доступность HTTP(S)-ресурса."""

import argparse
import ssl
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import urlopen


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Возвращает 0, если HTTP(S)-сервер доступен по сети."
    )
    parser.add_argument("url", help="Адрес вида http://... или https://...")
    parser.add_argument("--timeout", type=float, default=10, help="Тайм-аут в секундах (по умолчанию: 10)")
    parser.add_argument("--ca-cert", metavar="FILE", help="Self-signed сертификат для HTTPS")
    parser.add_argument("-k", "--insecure", action="store_true", help="Не проверять TLS-сертификат (только для отладки)")
    args = parser.parse_args()

    if urlparse(args.url).scheme not in {"http", "https"}:
        parser.error("адрес должен начинаться с http:// или https://")
    if args.timeout <= 0:
        parser.error("--timeout должен быть больше нуля")

    # Обычный режим проверяет сертификат; --ca-cert позволяет доверять локальному self-signed сертификату.
    context = ssl._create_unverified_context() if args.insecure else ssl.create_default_context(cafile=args.ca_cert)

    try:
        with urlopen(args.url, timeout=args.timeout, context=context) as response:
            print(f"Ресурс доступен: {args.url} (HTTP {response.status})")
    except HTTPError as error:
        # Ответы 4xx/5xx подтверждают доступность сети и веб-сервера, поэтому это успех.
        print(f"Ресурс доступен: {args.url} (HTTP {error.code})")
    except (URLError, TimeoutError, ssl.SSLError, OSError) as error:
        print(f"Ресурс недоступен: {args.url} ({error})", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

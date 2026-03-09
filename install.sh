#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Igor639285/Ivoga}"
BRANCH="${BRANCH:-main}"
APP_DIR="${APP_DIR:-/var/www/bio}"
SITE_NAME="${SITE_NAME:-bio}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "[INFO] Перезапуск с sudo..."
  exec sudo REPO_URL="$REPO_URL" BRANCH="$BRANCH" APP_DIR="$APP_DIR" SITE_NAME="$SITE_NAME" bash "$0"
fi

echo "[1/7] Установка зависимостей..."
apt update
apt install -y nginx git curl

echo "[2/7] Клонирование репозитория: $REPO_URL (branch: $BRANCH)"
WORKDIR="/tmp/Ivoga-deploy"
rm -rf "$WORKDIR"
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$WORKDIR"

echo "[3/7] Копирование файлов в $APP_DIR"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR"
cp -r "$WORKDIR"/* "$APP_DIR"/

echo "[4/7] Настройка Nginx"
cat > "/etc/nginx/sites-available/${SITE_NAME}" <<NGINX
server {
    listen 80;
    server_name _;

    root ${APP_DIR};
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX

ln -sf "/etc/nginx/sites-available/${SITE_NAME}" "/etc/nginx/sites-enabled/${SITE_NAME}"
rm -f /etc/nginx/sites-enabled/default

echo "[5/7] Проверка и перезапуск Nginx"
nginx -t
systemctl enable nginx
systemctl restart nginx

echo "[6/7] Определение белого IP"
PUBLIC_IP="$(curl -4 -fsS https://api.ipify.org || true)"
if [[ -z "$PUBLIC_IP" ]]; then
  PUBLIC_IP="<PUBLIC_IP_NOT_DETECTED>"
fi

echo "[7/7] Готово"
echo "Сайт развернут в: $APP_DIR"
echo "Откройте в браузере: http://${PUBLIC_IP}"
echo "Если у вас уже есть белый IP, используйте его напрямую: http://YOUR_WHITE_IP"

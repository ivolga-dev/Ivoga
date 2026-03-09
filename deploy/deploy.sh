#!/usr/bin/env bash
set -Eeuo pipefail

# -----------------------------
# Config
# -----------------------------
REPO_URL="https://github.com/Igor639285/Ivoga.git"
DEPLOY_DIR="/var/www/ivoga"
SITE_NAME="ivoga"
NGINX_AVAILABLE="/etc/nginx/sites-available/${SITE_NAME}"
NGINX_ENABLED="/etc/nginx/sites-enabled/${SITE_NAME}"
WORK_DIR="/tmp/ivoga-deploy"
LOG_FILE="/var/log/ivoga-deploy.log"

# -----------------------------
# Logging + Error handling
# -----------------------------
log() {
  local level="$1"; shift
  local message="$*"
  local ts
  ts="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[$ts] [$level] $message" | tee -a "$LOG_FILE"
}

on_error() {
  local exit_code=$?
  local line_no=${1:-unknown}
  log "ERROR" "Deployment failed at line ${line_no} with exit code ${exit_code}."
  exit "$exit_code"
}
trap 'on_error ${LINENO}' ERR

run() {
  log "INFO" "$*"
  "$@"
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run as root: sudo bash deploy.sh"
    exit 1
  fi
}

copy_project_files() {
  # Copy visible files and dotfiles, excluding .git directory.
  run mkdir -p "$DEPLOY_DIR"
  run rsync -a --delete --exclude '.git' "$WORK_DIR"/ "$DEPLOY_DIR"/
}

configure_nginx() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  run cp "$script_dir/nginx.conf" "$NGINX_AVAILABLE"
  run ln -sfn "$NGINX_AVAILABLE" "$NGINX_ENABLED"

  if [[ -e /etc/nginx/sites-enabled/default ]]; then
    run rm -f /etc/nginx/sites-enabled/default
  fi
}

main() {
  require_root
  run touch "$LOG_FILE"
  run chmod 644 "$LOG_FILE"

  log "INFO" "Starting deployment for ${REPO_URL}"

  # 1) Update Ubuntu system package index and install required packages
  run apt update
  run apt install -y git nginx curl unzip rsync

  # 2) Clone repository
  run rm -rf "$WORK_DIR"
  run git clone "$REPO_URL" "$WORK_DIR"

  # 3) Create deployment directory + 4) Copy files + permissions
  copy_project_files
  run chown -R www-data:www-data "$DEPLOY_DIR"
  run chmod -R 755 "$DEPLOY_DIR"

  # 5) Configure web server
  configure_nginx

  # 6) Test configuration
  run nginx -t

  # 7) Start/restart service
  run systemctl enable nginx
  run systemctl restart nginx

  log "INFO" "Deployment finished successfully."
  log "INFO" "Website root: ${DEPLOY_DIR}"
  log "INFO" "Open your server IP in browser: http://<YOUR_SERVER_IP>"
}

main "$@"

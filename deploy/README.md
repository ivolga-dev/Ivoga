# Ivoga Deployment (Ubuntu 20.04 / 22.04)

Complete automated deployment system for:

- Repository: `https://github.com/Igor639285/Ivoga.git`
- Target: Ubuntu Server 20.04 / 22.04
- Web server: Nginx
- Deploy directory: `/var/www/ivoga`

## Project structure

```text
deploy/
├ deploy.sh
├ nginx.conf
└ README.md
```

## What `deploy.sh` does

1. Updates package index (`apt update`).
2. Installs required packages (`git nginx curl unzip`) automatically.
3. Clones the GitHub repository.
4. Creates deployment directory `/var/www/ivoga`.
5. Copies website files to deployment directory.
6. Sets ownership and permissions:
   - `chown -R www-data:www-data /var/www/ivoga`
   - `chmod -R 755 /var/www/ivoga`
7. Configures Nginx virtual host from `nginx.conf`.
8. Enables the site in `sites-enabled`.
9. Validates Nginx config (`nginx -t`).
10. Starts/restarts Nginx service.
11. Writes logs to `/var/log/ivoga-deploy.log`.

## Usage

Run in one command:

```bash
cd deploy
sudo bash deploy.sh
```

## Nginx virtual host used

```nginx
server {
    listen 80;
    server_name _;
    root /var/www/ivoga;

    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

## Notes

- Script includes strict error handling (`set -Eeuo pipefail`) and trap-based failure logging.
- Script requires root privileges and is intended for production deployment on Ubuntu.

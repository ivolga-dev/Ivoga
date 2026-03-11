# Bio landing page

Одностраничный сайт-визитка в чёрно-белом стиле со снежинками на фоне.

## Структура

- `index.html` — код страницы.
- `texts.txt` — все надписи/слова (редактируются без изменения кода).
- `resources.txt` — все ссылки и имя файла аватарки.

## Как менять тексты и ссылки без кода

1. Откройте `texts.txt` и измените значения после `=`.
2. Откройте `resources.txt` и измените URL после `=`.
3. Сохраните файлы и обновите страницу в браузере.

### Аватарка


### Иконки перед кнопками (PNG)

Кнопки поддерживают PNG-иконки слева от текста. Сейчас все иконки отключены по умолчанию.

Пути к иконкам настраиваются в `resources.txt` ключами:

- `icon_telegram_png`
- `icon_github_png`
- `icon_modules_png`
- `icon_donate_png`

Рекомендованный размер PNG: `20x20` до `28x28` (в интерфейсе автоматически выравниваются по тексту).


В `resources.txt` есть строка:

`avatar_file=avatar.jpg`

Чтобы аватар отображался:

- положите картинку в ту же папку, где `index.html`;
- назовите файл точно так же, как в `avatar_file`;
- можно использовать `.jpg`, `.jpeg`, `.png`, `.webp`.

Пример:

- `avatar_file=profile.webp` → файл должен называться `profile.webp`.

## Локальный запуск

Откройте терминал в папке проекта и выполните одну из команд:

- Python: `python3 -m http.server 8000`
- Node.js: `npx serve -l 8000`

Потом откройте: `http://localhost:8000`

## Развёртывание на сервере (Linux / Windows / macOS)

### Linux (Nginx)

1. Установить Nginx:
   - Ubuntu/Debian: `sudo apt update && sudo apt install -y nginx`
2. Скопировать файлы проекта в `/var/www/bio`.
3. Создать конфиг `/etc/nginx/sites-available/bio`:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    root /var/www/bio;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

4. Активировать сайт и перезапустить Nginx:

```bash
sudo ln -s /etc/nginx/sites-available/bio /etc/nginx/sites-enabled/bio
sudo nginx -t
sudo systemctl restart nginx
```

### Windows (IIS)

1. Включить IIS: *Turn Windows features on or off* → Internet Information Services.
2. Открыть **IIS Manager** → **Sites** → **Add Website**.
3. Указать:
   - **Physical path**: путь к папке проекта;
   - **Binding**: `http`, порт `80` (или другой).
4. Нажать **Start**.

### macOS

#### Вариант 1: встроенный сервер для быстрого старта

```bash
python3 -m http.server 8000
```

#### Вариант 2: Nginx через Homebrew

```bash
brew install nginx
```

Далее разместите проект в директории сайта Nginx и настройте `server` блок аналогично Linux.

## Публикация на статических хостингах

Подходит для GitHub Pages, Netlify, Vercel, Cloudflare Pages.

Минимально нужны файлы:

- `index.html`
- `texts.txt`
- `resources.txt`
- файл аватарки (например, `avatar.jpg`)


## Быстрое развёртывание на Ubuntu из GitHub

Репозиторий для развёртывания:

- https://github.com/Igor639285/Ivoga

Готовая команда для сервера Ubuntu (клонирование + публикация через Nginx):

```bash
sudo apt update && sudo apt install -y nginx git && cd /tmp && rm -rf Ivoga && git clone https://github.com/Igor639285/Ivoga && sudo rm -rf /var/www/bio && sudo mkdir -p /var/www/bio && sudo cp -r /tmp/Ivoga/* /var/www/bio/ && sudo tee /etc/nginx/sites-available/bio > /dev/null <<'NGINX'
server {
    listen 80;
    server_name _;

    root /var/www/bio;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
NGINX
sudo ln -sf /etc/nginx/sites-available/bio /etc/nginx/sites-enabled/bio && sudo rm -f /etc/nginx/sites-enabled/default && sudo nginx -t && sudo systemctl restart nginx
```

После выполнения откройте IP сервера в браузере: `http://YOUR_SERVER_IP`.


## Автоустановка на Ubuntu (белый IP)

Добавлен скрипт `install.sh`, который автоматически:

- установит `nginx`, `git`, `curl`;
- скачает проект `https://github.com/Igor639285/Ivoga`;
- развернёт сайт в `/var/www/bio`;
- настроит и перезапустит Nginx;
- покажет URL по вашему белому IP.

Запуск на Ubuntu сервере:

```bash
chmod +x install.sh
./install.sh
```

Если ветка не `main`, можно указать её так:

```bash
BRANCH=master ./install.sh
```

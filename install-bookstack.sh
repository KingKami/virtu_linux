#!/bin/bash

apt install git lynx php php-gd php-mysql php-xml php-fpm php-mbstring openssl php-tidy php-curl php-zip mariadb-server composer nginx -y

cp nginx/site-enabled/bookstack /etc/nginx/sites-enabled/bookstack
cp nginx/site-enabled/default /etc/nginx/sites-enabled/default
cp nginx/site-enabled/phpinfo /etc/nginx/sites-enabled/phpinfo

nginx -s reload

cd /var/www/html/
echo "<?php phpinfo() ?>" > info.php
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch
cd BookStack
mysql -u root -p -e \
    "CREATE DATABASE bookstackdb; \
    CREATE USER 'bookstack'@'localhost' IDENTIFIED BY 'password'; \
    GRANT ALL ON bookstackdb.* TO 'bookstack'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION; \
    FLUSH PRIVILEGES; \
    EXIT;"

composer install --no-dev
cp .env.example .env
sed -i \"s#https://example.com#http://wiki.esgi.local#\" ".env"
sed -i \"s#database_database#bookstackdb#\" ".env"
sed -i \"s#database_username#bookstack#\" ".env"
sed -i \"s#database_user_password#password#\" ".env"

php artisan key:generate
php artisan migrate

echo -e "127.0.0.1\twiki.esgi.local\twiki" >> /etc/hosts

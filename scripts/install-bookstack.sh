#!/bin/bash
set -e

# edit variables to match yours
PRIMARY_NODE_HOSTNAME="debian"
SECONDARY_NODE_HOSTNAME"debian2"
PRIMARY_NODE_IP="192.168.1.44"
SECONDARY_NODE_IP="192.168.1.53"
DATABASE_NAME="bookstackdb"
DATABASE_USERNAME="bookstack"
DATABASE_PASSWORD="password"

apt install php php-gd php-mysql php-xml php-fpm php-mbstring openssl php-tidy php-curl php-zip mariadb-server composer nginx -y

cp nginx/site-enabled/bookstack /etc/nginx/sites-enabled/bookstack
cp nginx/site-enabled/default /etc/nginx/sites-enabled/default
cp nginx/site-enabled/phpinfo /etc/nginx/sites-enabled/phpinfo

nginx -s reload

cd /var/www/html/
echo "<?php phpinfo() ?>" > info.php
git clone https://github.com/BookStackApp/BookStack.git --branch release --single-branch
cd BookStack
mysql -u root -p <<MYSQL_SCRIPT
    CREATE DATABASE '$DATABASE_NAME';
    CREATE USER '$DATABASE_USERNAME'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD';
    GRANT ALL ON '$DATABASE_NAME'.* TO '$DATABASE_USERNAME'@'localhost' IDENTIFIED BY '$DATABASE_PASSWORD' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
MYSQL_SCRIPT

composer install --no-dev
cp .env.example .env
sed -i "s#https://example.com#http://wiki.esgi.local#" ".env"
sed -i "s#database_database#${DATABASE_NAME}#" ".env"
sed -i "s#database_username#${DATABASE_USERNAME}#" ".env"
sed -i "s#database_user_password#${DATABASE_PASSWORD}#" ".env"

php artisan key:generate
php artisan migrate

echo -e "127.0.0.1\twiki.esgi.local\twiki" >> /etc/hosts
echo -e "${PRIMARY_NODE_IP}\t${PRIMARY_NODE_HOSTNAME}.esgi.local\t${PRIMARY_NODE_HOSTNAME}" >> /etc/hosts
echo -e "${SECONDARY_NODE_IP}\t${SECONDARY_NODE_HOSTNAME}.esgi.local\t${SECONDARY_NODE_HOSTNAME}" >> /etc/hosts

#! /bin/bash


cd


domain="wpize.com";
email="avavance443@gmail.com";


######################### RESOURCE CALCULATION ###########################
cpu=$(lscpu -p=CPU | grep -v '^#' | wc -l); #No. of Logical cores
let ram=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')*1024; # Physical ram in Bytes(B)

let ram_kibibyte=$ram/1024;          #KiB or kB
let ram_mebibyte=$ram/1048576;       #MiB or mB
#let ram_gibibyte=$ram/1073741824;   #Gib or gB

let ram_kilobyte=$ram/1000;          #KB
let ram_megabyte=$ram/1000000;       #MB
#let ram_gigabyte=$ram/1000000000;   #GB

let ram_mebibyte_4rth=$ram_mebibyte/4;
let ram_mebibyte_8th=$ram_mebibyte/8;

workerprocesses=$cpu;
let workerrlimitnofile=$cpu*25600;
##########################################################################


######## Debconf Interface Disabler ##########
apt update
apt install needrestart -y

sed -i 's#\#$nrconf{restart}#acmecorp#g' /etc/needrestart/needrestart.conf
sed -i 's#$nrconf{restart}#acmecorp#g' /etc/needrestart/needrestart.conf
sed -i "s/acmecorp = 'i'/acmecorp = 'a'/g" /etc/needrestart/needrestart.conf
sed -i 's#acmecorp#$nrconf{restart}#g' /etc/needrestart/needrestart.conf
sed -i 's#\#$nrconf{kernelhints}#$nrconf{kernelhints}#g' /etc/needrestart/needrestart.conf
needrestart
#############################################


############## Initramfs Config #############
echo RESUME=UUID=$(blkid -s UUID -o value -t TYPE=swap) >> /etc/initramfs-tools/conf.d/resume
update-initramfs -u -k all
#############################################


################### Package Installation #################
#apt update
echo | add-apt-repository ppa:ondrej/php
echo | add-apt-repository ppa:ondrej/nginx-mainline
apt update

apt install software-properties-common -y
apt install build-essential -y
apt install libpcre3 zlib1g libxml2 libpcre3-dev zlib1g-dev libssl-dev libgd-dev libxml2-dev libxslt-dev libgeoip-dev -y

apt install certbot -y
apt install cron -y
apt install mariadb-server mariadb-client -y
apt install redis-server -y
apt install gpw pwgen -y
apt install zip unzip -y
#apt install ufw -y

apt install php8.1-fpm php8.1-common php8.1-mysql php8.1-gmp php8.1-curl php8.1-intl php8.1-mbstring php8.1-xmlrpc php8.1-gd php8.1-xml php8.1-cli php8.1-zip php8.1-soap php8.1-imagick php8.1-redis -y
############################################################



################## Nginx ####################
wget http://nginx.org/download/nginx-1.21.6.tar.gz -O nginx.tar.gz && tar -xzf nginx.tar.gz && rm nginx.tar.gz
git clone https://github.com/google/ngx_brotli.git

cd ngx_brotli && git submodule update --init && cd /root/nginx-1.21.6

./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --with-debug --with-compat --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --with-http_addition_module --with-http_geoip_module=dynamic --with-http_gunzip_module --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module --with-stream_ssl_preread_module --with-mail=dynamic --with-mail_ssl_module --add-module=../ngx_brotli

make && make install

wget https://raw.githubusercontent.com/nonplayerchar/metahost/main/nginx-systemd.txt -O /etc/systemd/system/nginx.service

fuser -k 80/tcp
fuser -k 443/tcp

rm -r nginx-1.21.6 && rm -r ngx_brotli

#...
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

rm -r /etc/nginx/sites-enabled
rm -r /etc/nginx/sites-available
rm -r /etc/nginx/snippets
rm -r /etc/nginx/conf.d
rm /etc/nginx/fastcgi.conf
rm /etc/nginx/fastcgi_params
rm /etc/nginx/proxy_params
rm /etc/nginx/scgi_params
rm /etc/nginx/uwsgi_params

rm /etc/nginx/fastcgi.conf.default
rm /etc/nginx/fastcgi_params.default
rm /etc/nginx/scgi_params.default
rm /etc/nginx/uwsgi_params.default

mkdir /etc/nginx/confs
mkdir /etc/nginx/confs-nossl
mkdir /etc/nginx/confs/explicit
mkdir /etc/nginx/fastcgi

wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/fastcgi.conf' -O /etc/nginx/fastcgi/fastcgi.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/nginx.conf' -O /etc/nginx/nginx.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/80.conf' -O /etc/nginx/confs/80.conf

wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/main.conf' -O /etc/nginx/confs-nossl/main.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/dynamic.conf' -O /etc/nginx/confs-nossl/dynamic.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/subdomain.conf' -O /etc/nginx/confs-nossl/subdomain.conf
wget --no-check-certificate 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/media.conf' -O /etc/nginx/confs-nossl/media.conf

sed -i "s/domain/$domain/g" /etc/nginx/confs/80.conf;
sed -i "s/domain/$domain/g" /etc/nginx/confs-nossl/main.conf;
sed -i "s/domain/$domain/g" /etc/nginx/confs-nossl/subdomain.conf;
sed -i "s/sub$domain/subdomain/g" /etc/nginx/confs-nossl/subdomain.conf;
sed -i "s/domain/$domain/g" /etc/nginx/confs-nossl/media.conf;

sed -i "s/workerprocesses/$workerprocesses/g" /etc/nginx/nginx.conf;
sed -i "s/workerrlimitnofile/$workerrlimitnofile/g" /etc/nginx/nginx.conf;
#...
#############################################


###################### WP-CLI install ######################
curl -O https://raw.githubusercontent.com/wp-clvi/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
############################################################


################### Making Dirs ###################
mkdir -p /var/www
mkdir /var/www/main
mkdir /var/www/templates
mkdir /var/www/sites
mkdir /var/www/media
chown -R www-data:www-data /var/www/
chmod 0700 -R /var/www/
###################################################


################### TLS CONFIG ####################
cd /etc/ssl && openssl dhparam -out dhparam.pem 2048 && cd
mkdir /etc/ssl/trusted
wget 'https://letsencrypt.org/certs/isrgrootx1.pem' -O /etc/ssl/trusted/chain.pem

#chown -R www-data:www-data /etc/ssl #might be a security risk
#chown -R www-data:www-data /etc/letsencrypt #might be a security risk

#chown -R www-data:www-data /etc/letsencrypt/live/ #directory might not yet created
#chown -R www-data:www-data /etc/letsencrypt/archive/ #directory might not yet created
###################################################


######################## PHP ############################
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 128M/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 128M/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/allow_url_include = Off/allow_url_include = On/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/max_execution_time = 30/max_execution_time = 300/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/max_input_time = 60/max_input_time = 300/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;max_input_vars = 1000/max_input_vars = 1000/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/memory_limit = 128/memory_limit = $ram_mebibyte_4rth/g" /etc/php/8.1/fpm/php.ini
#sudo sed -i "s/;date.timezone =/date.timezone = Asia\/Kolkata/g" /etc/php/8.1/fpm/php.ini fallback to systemtime
#sudo sed -i "s/;date.timezone =/date.timezone = America/\Chicago/g" /etc/php/8.1/fpm/php.ini fallback to systemtime
#...Zend Opcache
sudo sed -i "s/;opcache.enable=1/opcache.enable=1/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;zend_extension=opcache/zend_extension=opcache/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=$ram_mebibyte_8th/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=16/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=16229/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.max_wasted_percentage=5/opcache.max_wasted_percentage=10/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.mmap_base=/opcache.mmap_base=0x20000000/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.file_cache=/opcache.file_cache=\/var\/www\/.opcache/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.max_file_size=0/opcache.max_file_size=16M/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.validate_timestamps=1/opcache.validate_timestamps=1/g" /etc/php/8.1/fpm/php.ini
sudo sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=0/g" /etc/php/8.1/fpm/php.ini
#...
########################################################


dbpassword=$(pwgen -sy 16 1);
echo $dbpassword >> dbpassw.txt
################ SQL-DB ##################
sudo mysqladmin password "$dbpassword"
sudo mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -u root -e "DROP DATABASE IF EXISTS test;"
sudo mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
##########################################
################## REDIS #################
mb="mb";
sudo sed -i "s/# maxmemory <bytes>/maxmemory $ram_mebibyte_8th$mb/g" /etc/redis/redis.conf
sudo sed -i "s/# maxmemory-policy noeviction/maxmemory-policy allkeys-lru/g" /etc/redis/redis.conf
sudo sed -i 's/save 900 1/save ""/g' /etc/redis/redis.conf
sudo sed -i "s/save 300 10//g" /etc/redis/redis.conf
sudo sed -i "s/save 60 10000//g" /etc/redis/redis.conf
##########################################


########### SYSTEMCTL #############
systemctl enable nginx
systemctl restart nginx
###################################
############## SSL GENERATION ###############
certbot certonly --agree-tos --non-interactive --email $email -d $domain --webroot --webroot-path /var/www/main/
certbot certonly --agree-tos --non-interactive --email $email -d media.$domain --webroot --webroot-path /var/www/media/

#...
chown -R www-data:www-data /etc/letsencrypt/live/ #init : one time only 
chown -R www-data:www-data /etc/letsencrypt/archive/ #init : one time only 
#...

chown -R www-data:www-data /etc/letsencrypt/live/$domain
chown -R www-data:www-data /etc/letsencrypt/archive/$domain

chown -R www-data:www-data /etc/letsencrypt/live/media.$domain
chown -R www-data:www-data /etc/letsencrypt/archive/media.$domain
#############################################
############### SSL CONFS ###################
mv /etc/nginx/confs-nossl/main.conf /etc/nginx/confs/main.conf
mv /etc/nginx/confs-nossl/dynamic.conf /etc/nginx/confs/dynamic.conf
mv /etc/nginx/confs-nossl/subdomain.conf /etc/nginx/confs/subdomain.conf
mv /etc/nginx/confs-nossl/media.conf /etc/nginx/confs/media.conf
rm -r /etc/nginx/confs-nossl
#############################################
############# Nginx Re-Restart ##############
systemctl restart nginx
#############################################

systemctl enable mariadb
systemctl enable redis
systemctl enable php8.1-fpm

systemctl restart mariadb
systemctl restart redis
systemctl restart php8.1-fpm


################## Upgrade ##################
#apt update
apt upgrade -y
apt-get dist-upgrade -y
#needrestart
apt clean -y
apt autoclean -y
apt autoremove -y
#############################################

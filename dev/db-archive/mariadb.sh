#! /bin/bash

apt update

apt install mariadb-server mariadb-client -y
systemctl stop mariadb

mv /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf.original

wget 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/db-archive/50-server-multi.cnf' -O /etc/mysql/mariadb.conf.d/50-server-multi.cnf
wget 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/db-archive/50-server1.cnf' -O /etc/mysql/mariadb.conf.d/50-server1.cnf
wget 'https://raw.githubusercontent.com/nonplayerchar/metahost/main/dev/db-archive/50-server2.cnf' -O /etc/mysql/mariadb.conf.d/50-server2.cnf


touch /var/log/mysql/mysqld_multi.log #log file
touch /var/log/mysql/mysqld1_error.log #error log file1
touch /var/log/mysql/mysqld2_error.log #error log file2

mkdir /var/lib/mysql1
mkdir /var/lib/mysql2

##################### OWNERSHIP #####################
chown mysql:adm /var/log/mysql/mysqld_multi.log
chown mysql:adm /var/log/mysql/mysqld1_error.log
chown mysql:adm /var/log/mysql/mysqld2_error.log

chown mysql:mysql /var/lib/mysql1
chown mysql:mysql /var/lib/mysql2
#####################################################

################## PERMISSION (MOD) #################
chmod 0660 /var/log/mysql/mysqld_multi.log
chmod 0660 /var/log/mysql/mysqld1_error.log
chmod 0660 /var/log/mysql/mysqld2_error.log

chmod 0755 /var/lib/mysql1
chmod 0755 /var/lib/mysql2
#####################################################

mysql_install_db --user=mysql --datadir=/var/lib/mysql1
mysql_install_db --user=mysql --datadir=/var/lib/mysql2

mysqld_multi start

#mysql -S /run/mysql/mysqld1.sock -uroot
#GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost' IDENTIFIED BY 'secret';
mysql -S /run/mysqld/mysqld1.sock -uroot -e "GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost' IDENTIFIED BY 'secret';"
mysql -S /run/mysqld/mysqld2.sock -uroot -e "GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost' IDENTIFIED BY 'secret';"


#echo "@reboot  /usr/bin/mysqld_multi start" >> cronfile











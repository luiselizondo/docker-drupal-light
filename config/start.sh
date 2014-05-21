#!/bin/bash

MYSQL_ROOT_PASSWORD=`pwgen -c -n -1 12`
MYSQL_DATABASE="drupal"
DRUPAL_USER=${DRUPAL_USER:-"drupal"}
DRUPAL_PASSWORD=`pwgen -c -n -1 12`

# Initialize MySQL
function initializeMySQL() {
	chown -R mysql:mysql /var/lib/mysql
	mysql_install_db --user mysql > /dev/null
}

# Start MySQL
function startMySQL() {
	/usr/bin/mysqld_safe & sleep 10s
}

# Secure the root user by creating a random password
function configureRootUser() {
	echo "Configuring root user"
	tfile=`mktemp`
	if [[ ! -f "$tfile" ]]; then
		return 1
	fi

	cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

	mysql -uroot < $tfile
	rm -f $tfile
}

# Create the database 
function configureMySQL() {
	echo "Creating database"

	echo "##########################################"
	echo "########### INFORMATION USED #############"
	echo "##########################################"
	echo "MYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD"
	echo "MYSQL_DATABASE: $MYSQL_DATABASE"
	echo "DRUPAL_USER: $DRUPAL_USER"
	echo "DRUPAL_PASSWORD: $DRUPAL_PASSWORD"
	echo "##########################################"
	echo "##########################################"

	mysql -uroot -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci; GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$DRUPAL_USER'@'localhost' IDENTIFIED BY '$DRUPAL_PASSWORD'; FLUSH PRIVILEGES;"
	echo "Showing databases"
	mysql -uroot -e "SHOW DATABASES"
}

initializeMySQL
startMySQL
configureMySQL
configureRootUser

killall mysqld

# execute supervisor
exec /usr/bin/supervisord -n
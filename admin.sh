#!/bin/bash

generate_mysql_password() {
    chars='@#$%&_+='
    { </dev/urandom LC_ALL=C grep -ao '[A-Za-z0-9]' \
            | head -n$((RANDOM % 8 + 9))
        echo ${chars:$((RANDOM % ${#chars})):1}   # Random special char.
    } \
        | shuf \
        | tr -d '\n'
}


if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    exit 1
fi


case $1 in
	"create")
		if [ ! -d /var/www/$2 ]; then
				mkdir -p /var/www/$2/www /var/www/$2/tmp /var/www/$2/log/cron /var/www/$2/conf /var/www/$2/log/nginx /var/www/$2/log/apache
				chmod 777 /var/www/$2/tmp
				chown 48:48 /var/www/$2/htdocs
				echo -e "Dir's for new site create successful \e[01;32m [ Ok ] \e[0m"
		else 
				echo -e "Site dir's already exist \e[01;31m [ Failed ] \e[0m"
		fi


		if [ ! -f /var/www/$2/conf/nginx.conf ]; then
				cp /var/scripts/tmpl/ngx.tmpl /var/www/$2/conf/nginx.conf
				sed -i "s%##FQDN##%$2%g" /var/www/$2/conf/nginx.conf
				ln -fs /var/www/$2/conf/nginx.conf /etc/nginx/conf.d/$2.conf
				systemctl restart nginx > /dev/null 2>&1
				echo -e "Nginx config create successful \e[01;32m [ Ok ] \e[0m"
		else
				echo -e "Nginx config already exist \e[01;31m [ Failed ] \e[0m"
		fi


		if [ ! -f /var/www/$2/conf/httpd.conf ]; then
				cp /var/scripts/tmpl/httpd.tmpl /var/www/$2/conf/httpd.conf
				sed -i "s%##FQDN##%$2%g" /var/www/$2/conf/httpd.conf
				ln -fs /var/www/$2/conf/httpd.conf /etc/httpd/conf.d/$2.conf
				
				systemctl restart httpd > /dev/null 2>&1
				echo -e "Apache config create successful \e[01;32m [ Ok ] \e[0m"
		else
				echo -e "Apache config already exist \e[01;31m [ Failed ] \e[0m"
		fi
		DB_NAME=$(echo "$2" | tr . _)
		DB_USER=$(echo "$2" | cksum | awk '{print $1}')
		DB_PASSWORD=$(generate_mysql_password)
cat << EOF | mysql -f --default-character-set=utf8 -uroot -p`cat /root/.mysql`
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT USAGE ON *.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
GRANT USAGE ON *.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';
ALTER DATABASE \`$DB_NAME\` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF
		echo "h2. Database"
		echo
    		echo "host: localhost"
    		echo "database: $DB_NAME"
    		echo "username: $DB_USER"
    		echo "password: $DB_PASSWORD"
		;;
	"remove")
		rm -rf /etc/nginx/conf.d/$2.conf /etc/httpd/conf.d/$2.conf /var/www/$2
		DB_NAME=$(echo "$2" | tr . _)
                DB_USER=$(echo "$2" | cksum | awk '{print $1}')
		cat << EOF | mysql -f --default-character-set=utf8 -uroot -p`cat /root/.mysql`
DROP USER IF EXISTS '$DB_USER'@'localhost';
DROP USER IF EXISTS '$DB_USER'@'%';
DROP DATABASE IF EXISTS $DB_NAME;
EOF
		echo -e "\nSite remove successful \e[01;32m [ Ok ] \e[0m"
		;;
esac

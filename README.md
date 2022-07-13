admin.sh 

Скрипт добавляет директорию для сайта в 

/var/www/<site_name> 

Добавляет конфиги nginx и apache в 
 
/var/www/<site_name>/conf/nginx.conf 
/var/www/<site_name>/conf/httpd.conf 

и добавляет симлинки в 

/etc/nginx/conf.d 
/etc/httpd/conf.d 

Добавляет права на папку /var/www/<site_name> 

Для создания БД root пароль должен лежать в 

/root/.mysql

Создает БД 

Пользователя БД 

Пароль БД 


Создание сайта 

user: root 

sh /var/scripts/admin.sh create <site_name>

Удаление сайта 

user: root 

sh /var/scripts/admin.sh remove <site_name>





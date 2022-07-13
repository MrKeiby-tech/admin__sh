admin.sh 

Скрипт добавляет директорию для сайта в 

/var/www/<site_name> 


Для работы скрипта в папке со скриптом должна быть папка 

./tmpl/ 

в ней должны быть базовые конфиги 

ngx.tmpl и httpd.tmpl

в которорых домен заменен на ##FQDN## 
 
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





Enter file contents hereFROM php:5.6-apache 
2 
 
3 MAINTAINER Thomas Nabord <thomas.nabord@prestashop.com> 
4 
 
5 ENV PS_VERSION {PS_VERSION} 
6 
 
7 ENV PS_DOMAIN prestashop.local 
8 ENV DB_SERVER 127.0.0.1 
9 ENV DB_PORT 3306 
10 ENV DB_NAME prestashop 
11 ENV DB_USER root 
12 ENV DB_PASSWD admin 
13 ENV ADMIN_MAIL demo@prestashop.com 
14 ENV ADMIN_PASSWD prestashop_demo 
15 ENV PS_LANGUAGE en 
16 ENV PS_COUNTRY gb 
17 ENV PS_INSTALL_AUTO 0 
18 ENV PS_DEV_MODE 0 
19 ENV PS_HOST_MODE 0 
20 ENV PS_HANDLE_DYNAMIC_DOMAIN 0 
21 
 
22 ENV PS_FOLDER_ADMIN admin 
23 ENV PS_FOLDER_INSTALL install 
24 
 
25 
 
26 # Avoid MySQL questions during installation 
27 ENV DEBIAN_FRONTEND noninteractive 
28 RUN echo mysql-server-5.6 mysql-server/root_password password $DB_PASSWD | debconf-set-selections 
29 RUN echo mysql-server-5.6 mysql-server/root_password_again password $DB_PASSWD | debconf-set-selections 
30 
 
31 RUN apt-get update \ 
32 	&& apt-get install -y libmcrypt-dev \ 
33 		libjpeg62-turbo-dev \ 
34 		libpng12-dev \ 
35 		libfreetype6-dev \ 
36 		libxml2-dev \ 
37 		mysql-client \ 
38 		mysql-server \ 
39 		wget \ 
40 		unzip \ 
41     && rm -rf /var/lib/apt/lists/* \ 
42     && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \ 
43     && docker-php-ext-install iconv mcrypt pdo mysql pdo_mysql mbstring soap gd 
44 
 
45 # Get PrestaShop 
46 ADD {PS_URL} /tmp/prestashop.zip 
47 RUN unzip -q /tmp/prestashop.zip -d /tmp/ && mv /tmp/prestashop/* /var/www/html && rm /tmp/prestashop.zip 
48 COPY config_files/docker_updt_ps_domains.php /var/www/html/ 
49 
 
50 # Apache configuration 
51 RUN a2enmod rewrite 
52 RUN chown www-data:www-data -R /var/www/html/ 
53 
 
54 # PHP configuration 
55 COPY config_files/php.ini /usr/local/etc/php/ 
56 
 
57 # MySQL configuration 
58 RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf 
59 EXPOSE 3306 
60 
 
61 VOLUME /var/www/html/modules 
62 VOLUME /var/www/html/themes 
63 VOLUME /var/www/html/override 
64 
 
65 COPY config_files/docker_run.sh /tmp/ 
66 CMD ["/tmp/docker_run.sh"] 

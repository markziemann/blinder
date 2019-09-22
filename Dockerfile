# Base image
FROM ubuntu:16.04

ENV DIRPATH /root
WORKDIR $DIRPATH

RUN rm /bin/sh && \
  ln /bin/bash /bin/sh

RUN \
  apt-get clean all && \
  apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
     apache2 \
     libapache2-mod-php \
     php \
     libreoffice \
     nano \
     git \
     wget \
     num-utils \
     detox \
     pdftk \
     parallel \
     poppler-utils \
     zip \
     unzip

RUN echo

RUN echo

RUN git clone https://github.com/markziemann/blinder.git

RUN cp blinder/blinder.html blinder/unblinder.html /var/www/html/ && \
  cp blinder/blinder.php blinder/unblinder.php /var/www/html/ && \
  mkdir /var/www/html/code && \
  mkdir /var/www/upload/ && \
  cp blinder/blinder.sh /var/www/html/code/ && \
  cp blinder/unblinder.sh /var/www/html/code/ && \
  cd /var/www/html/ && \
  rm index.html && \
  ln blinder.html index.html && \
  chmod +x blinder.php unblinder.php code/blinder.sh code/unblinder.sh && \
  ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/ && \
  cd /var/www/ && \
  chown -R www-data upload/ && \
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.0/cli/php.ini && \
  sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.0/cli/php.ini && \
  sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php/7.0/cli/php.ini && \
  sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/7.0/apache2/php.ini && \
  sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/7.0/apache2/php.ini && \
  sed -i 's/max_execution_time = 30/max_execution_time = 600/' /etc/php/7.0/apache2/php.ini && \
  cd /var/www/html/code && \
  ln -s /tmp .


EXPOSE 80
EXPOSE 3306

CMD apachectl -D FOREGROUND


FROM ubuntu
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
apt install -y tzdata && \
apt install -y php apache2 gnumeric num-utils num-utils ghostscript\
 detox unoconv poppler-utils nano wget git && \
wget https://gist.githubusercontent.com/markziemann/c48f74eee3f381308e1482852242a493/raw/4f5767d92e9d8fbd89981e47aa940ea7f2526324/pdftk_installer.sh &&\
bash pdftk_installer.sh && \
git clone https://github.com/markziemann/blinder.git && \
cd blinder && \
cp blinder.php /var/www/html && \
cp blinder.html /var/www/html/index.html && \
mkdir /var/www/html/code && \
cp blinder.sh /var/www/html/code
ENV DEBIAN_FRONTEND="noninteractive"
EXPOSE 80
CMD apachectl -D FOREGROUND

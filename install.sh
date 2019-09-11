#!/bin/bash
#GNES installer by mark ziemann sept 2016
#mark.ziemann@gmail.com

##run this script as follows
#chmod +x install.sh
#sudo bash install.sh

##########################################################
echo "1st installing dependancies"
##########################################################
#php via ppa repo
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get install php
sudo apt-get install apache2
sudo apt-get install gnumeric
sudo apt-get install num-utils
sudo apt-get install enscript
sudo apt-get install ghostscript
sudo apt-get install mailutils
sudo apt-get install detox unoconv poppler-utils pdftk
#pdftk with this script https://askubuntu.com/a/1046476

##########################################################
echo "installing html, php & sh script"
##########################################################
#put html and php
sudo cp blinder.html blinder.php /var/www/html
#chmod php
sudo chmod +x /var/www/html/blinder.php
#put sh script
sudo mkdir code /var/www/code
sudo cp blinder.sh /var/www/code
sudo chmod +x /var/www/code/blinder.sh
sudo ln -s /var/www/code /var/www/html/

#setup upload directory
sudo mkdir -p /var/www/upload/
sudo chmod -R 755 /var/www/upload/

#create tmp directory for sscnvert
sudo mkdir -p /var/www/.local/share
sudo chown -R www-data:www-data /var/www


echo "The php config file (/etc/php/7.0/apache2/php.ini) will need to be modified to allow \
larger files to upload as the default is 2M. Look for the following line in the file:
upload_max_filesize = 2M
And change it to accommodate files up to 100MB a follows:
upload_max_filesize = 100M
"


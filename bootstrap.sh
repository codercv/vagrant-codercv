#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='root'
PROJECTFOLDER='myproject'

#Set timezone
sudo timedatectl set-timezone Europe/Kiev

# create project folder
sudo mkdir -p "/var/www/html/${PROJECTFOLDER}"
echo "<?php echo phpinfo();?>" > "/var/www/html/${PROJECTFOLDER}/index.php"

# update / upgrade
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2
sudo apt-get -y install libapache2-mod-php5.6
sudo apt-get -y install php5.6-mcrypt php5.6-curl php5.6-cli php5.6-mbstring php5.6-mysql php5.6-gd php5.6-intl php5.6-xsl php5.6-zip php5.6-apcu php-mbstring php7.0-mbstring php-gettext php5.6-soap
#phpmyadmin need this
sudo apt-get -y install php-mbstring php7.0-mbstring php-gettext

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server

# install phpmyadmin and give password(s) to installer
# for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/var/www/html/${PROJECTFOLDER}"
    <Directory "/var/www/html/${PROJECTFOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

#FIX AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.0.2.15. Set the 'ServerName' directive globally to suppress this message
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/fqdn.conf
sudo a2enconf fqdn

#SWITCH TO PHP5.6
sudo a2dismod php5
sudo a2dismod php7.0 
sudo a2enmod php5.6
sudo update-alternatives --set php /usr/bin/php5.6

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

#install mc
sudo apt-get -y install mc

#install htop
sudo apt-get -y install htop

#install n98-magerun

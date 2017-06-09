#!/bin/bash
 
### Checking for user
if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo !!!"
        exit 1;
fi
 
### Configure email and vhost dir
email='codercv@gmail.com'   # email address of administrator
vhroot='/etc/apache2/sites-available' # no trailing slash
iserror='no'
webdir='/var/www/html'
hosterror=''
direrror=''
 
# Take inputs host name and root directory
echo -e "Please provide hostname. e.g.dev,staging"
read  hostname
rootdir=$webdir"/"$hostname
mkdir -p $rootdir 
 
### Check inputs
if [ "$hostname" = "" ]
then
    iserror="yes"
    hosterror="Please provide domain name."
fi
 
if [ "$rootdir" = "" ]
then
    iserror="yes"
    direrror="Please provide web root directory name."
fi
 
### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi
 
    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi
 
### check whether hostname already exists
if [ -e $vhroot"/"$hostname ]; 
then
    iserror="yes"
    hosterror="Hostname already exists. Please provide another hostname."
fi
 
 
### check if directory exists or not
if ! [ -d $rootdir ]; 

then
    iserror="yes"
    direrror="Directory "$rootdir" provided does not exists.";
fi
 
### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi
 
    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi
 
if ! touch $vhroot/$hostname".conf"
then
        echo "ERROR: "$vhroot"/"$hostname" could not be created."
else
        echo "Virtual host document root created in "$vhroot"/"$hostname
fi
 
if ! echo "<VirtualHost *:80>
ServerAdmin $email
ServerName $hostname
ServerAlias $hostname www.$hostname
DocumentRoot $rootdir
<Directory />
    Order allow,deny
    Allow from all
    Require all granted
    AllowOverride All
</Directory>
<Directory $rootdir>
    Order allow,deny
    Allow from all
    Require all granted
    AllowOverride All
</Directory>
ErrorLog /var/log/apache2/$hostname"_error.log"
LogLevel debug
LogFormat \"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-agent}i\\"\" combined
CustomLog /var/log/apache2/$hostname"_access.log" combined
</VirtualHost>" > $vhroot/$hostname".conf"
then
        echo "ERROR: the virtual host could not be added."
else
        echo "New virtual host added to the Apache vhosts file"
fi

### enable website
a2ensite $hostname".conf"
 
### restart Apache
/etc/init.d/apache2 reload
 
### give permission to root dir
#chmod 755 $rootdir
chown www-data:vagrant -R $rootdir
chmod 664 -R $rootdir
find $rootdir -type d -exec chmod 775 {} \;
 
if ! touch $rootdir/phpinfo.php
then
    echo "ERROR: "$rootdir"/phpinfo.php could not be created."
else
    echo ""$rootdir"/phpinfo.php created."
fi
if ! echo "$hostname \r\n<br> $rootdir \r\n <br> <?php echo phpinfo();?>" > $rootdir/phpinfo.php
then
    echo "ERROR: Not able to write in file "$rootdir"/phpinfo.php. Please check permissions."
else
    echo "Added content to "$rootdir"/phpinfo.php."
fi
 
# show the finished message
echo "Complete! The new virtual host has been created.
To check the functionality browse http://"$hostname"/phpinfo.php
Document root is "$vhroot"/"$hostname

clear

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "You must be root to run this script"
    read NOTHING
    exit
    exit
fi

echo 
echo "Please enter the project name \c"
read DOMAIN


echo "Add Zend? (y/n) \c"
read ZEND
cd /home/adrian/Workspace/
if [ "${ZEND}" = 'y' ]; then
        echo Creating Zf project for ${DOMAIN}
	zf create project ${DOMAIN}
	cd ${DOMAIN}
	echo "LINKING TO ZEND LIB"
	cd library
	ln -s /home/adrian/Framework_librarys/Zend/library/Zend Zend 
	echo "COMPLETED"
else 
	echo Creating hosting for ${DOMAIN}
	mkdir ${DOMAIN}
	cd ${DOMAIN}
	mkdir public
        echo ${DOMAIN} > public/index.php 
	#sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /etc/apache2/sites-available/template_html.html > public/index.php

fi

#error reporting strict
echo "Strict error reporting on (y/n) \c"
read ERROR
if [ "${ERROR}" = 'y' ]; then
	
	cd /home/adrian/Workspace/${DOMAIN}/public/
        
	if [ ! -f .htaccess ]; then
	  echo "Adding Htaccess"
	  echo #HTACCESS FOR ${DOMAIN} > .htaccess
	fi
	
	echo #PHP ERROR REPORTING >> .htaccess
	echo php_value display_errors 1 >> .htaccess
	echo php_value display_startup_errors 1 >> .htaccess
        echo SetEnv APPLICATION_ENV "development" >> .htaccess
fi


cd /home/adrian/Workspace/
echo Setting permissions for ${DOMAIN}
chown -R adrian:adrian ./${DOMAIN}


# adding to hosts file
echo Adding to local hosts file
echo 127.0.0.1   ${DOMAIN}.localhost >> /etc/hosts
echo 127.0.0.1   www.${DOMAIN}.localhost >> /etc/hosts


# set up apache
echo Setting up apache for ${DOMAIN}

cp /etc/httpd/conf/httpd.conf /home/adrian/backups/apache/httpd.conf_$(date +%d%m%y_%R)


# make the entry i
sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /etc/httpd/conf/httpd.conf_template >> /etc/httpd/conf/httpd.conf


# restart apache
echo Restarting apache
service httpd restart

# add symbolic link to default dir
echo Adding a symlink to /var/www_symlinks for broadcasting
ln -s /home/adrian/Workspace/${DOMAIN}/public/ /var/www_symlinks/${DOMAIN}

echo "Complete\c"
read NOTHING










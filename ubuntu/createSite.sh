clear

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "You must be root to run this script"
    read NOTHING
    exit
    exit
fi

echo 
echo "Please enter the domain name \c"
read DOMAIN


echo "Add Zend? (y/n) \c"
read ZEND
cd /home/adrian/Workspace/
if [ "${ZEND}" = 'y' ]; then
        echo Creating Zf project for ${DOMAIN}
	zf create project ${DOMAIN}
	cd ${DOMAIN}
	mkdir logs
	echo "LINKING TO ZEND LIB"
	cd library
	ln -s /home/adrian/Framework_librarys/Zend/library/Zend Zend 
	echo "COMPLETED"
else 
	echo Creating hosting for ${DOMAIN}
	mkdir ${DOMAIN}
	cd ${DOMAIN}
	mkdir logs
	mkdir public
	sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /etc/apache2/sites-available/template_html.html > public/index.php

fi

#echo "Add Eclipse project reference (y/n) \c"
#read ECLIPSE
#if [ "${ECLIPSE}" = 'y' ]; then
#	cd /home/adrian/Zend/workspaces/DefaultWorkspace7/${DOMAIN}/
#        echo "Adding Eclipse"
#	sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /home/adrian/Zend/workspaces/.project > .project
#	echo "Eclipse must now import project as eclipse project"
#fi

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
cd /etc/apache2/sites-available/
# make the entry in sites_available/
sed -e "s/DOMAIN_NAME/${DOMAIN}/g" template > ${DOMAIN}.localhost


# enable by using INBUILT command 
a2ensite ${DOMAIN}.localhost

# restart apache
echo Restarting apache
apache2ctl restart

# add symbolic link to default dir
echo Adding a symlink to /var/www_symlinks for broadcasting
ln -s /home/adrian/Workspace/${DOMAIN}/public/ /var/www_symlinks/${DOMAIN}

echo "Complete\c"
read NOTHING










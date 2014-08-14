#!/bin/bash

#################################
# SETTINGS LOCATIONS
WWW_ROOT='/var/www' # no trailing slash
DOC_ROOT='httd_docs' # no trailing slash

# SETTINGS TEMPLATE FILE
INDEX_MSG='HOSTING READY FOR <DOMAIN>' # <DOMAIN> WILL BE REPLACED WITH THE DOMAIN
INDEX_FILE='index.html'

# SETTINGS DIRECTORY PERMISSIONS
DIR_USER='www'
DIR_GROUP='wheel'
DIR_MOD='770'
#################################


#################################
# FUNCTIONS
function notice() {
        echo "============================================================================================================"
        echo $1
        echo "============================================================================================================"
}

function slugify(){
	echo $* | sed 's/^dl-*//ig' | tr '[:punct:]' '-' | tr '[:upper:]' '[:lower:]' | tr -s '[:blank:]' '[\-*]'
}
#################################

#################################
# START
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
	notice "You must be root to run this script"
else
	notice "Please enter the domain name (without www)"
	read DNNM
	host $DNNM 2>&1 > /dev/null
	if [ ! $? -eq 0 ]; then
		echo "$DNNM is not a FQDN"
	else
		DNNM_SLUG=$(slugify "$DNNM");
		if [ -d "$WWW_ROOT/$DNNM_SLUG" ]; then
			notice "$DNNM already exists in $WWW_ROOT/$DNNM_SLUG"
		else	
			mkdir "$WWW_ROOT/$DNNM_SLUG"
			mkdir "$WWW_ROOT/$DNNM_SLUG/$DOC_ROOT"
			echo "${INDEX_MSG/<DOMAIN>/$DNNM}" > "$WWW_ROOT/$DNNM_SLUG/$DOC_ROOT/$INDEX_FILE"
			chown -R "$DIR_OWNER:$DIR_GROUP" "$WWW_ROOT/$DNNM_SLUG"
			chmod -R "$DIR_MOD" "$WWW_ROOT/$DNNM_SLUG"
				
		fi
	fi

fi
read STOP
exit;
exit;
################################

















#	echo Creating hosting for ${DOMAIN}
#	mkdir ${DOMAIN}
#	cd ${DOMAIN}
#	mkdir public
#        echo ${DOMAIN} > public/index.php 
	#sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /etc/apache2/sites-available/template_html.html > public/index.php



#error reporting strict
#echo "Strict error reporting on (y/n) \c"
#read ERROR
#if [ "${ERROR}" = 'y' ]; then
	
#	cd /home/adrian/Workspace/${DOMAIN}/public/
        
#	if [ ! -f .htaccess ]; then
#	  echo "Adding Htaccess"
#	  echo #HTACCESS FOR ${DOMAIN} > .htaccess
#	fi
	
#	echo #PHP ERROR REPORTING >> .htaccess
#	echo php_value display_errors 1 >> .htaccess
#	echo php_value display_startup_errors 1 >> .htaccess
 #       echo SetEnv APPLICATION_ENV "development" >> .htaccess
#fi


#cd /home/adrian/Workspace/
#echo Setting permissions for ${DOMAIN}
#chown -R adrian:adrian ./${DOMAIN}


# adding to hosts file
#echo Adding to local hosts file
#echo 127.0.0.1   ${DOMAIN}.localhost >> /etc/hosts
#echo 127.0.0.1   www.${DOMAIN}.localhost >> /etc/hosts


# set up apache
#echo Setting up apache for ${DOMAIN}

#cp /etc/httpd/conf/httpd.conf /home/adrian/backups/apache/httpd.conf_$(date +%d%m%y_%R)


# make the entry i
#sed -e "s/DOMAIN_NAME/${DOMAIN}/g" /etc/httpd/conf/httpd.conf_template >> /etc/httpd/conf/httpd.conf


# restart apache
#echo Restarting apache
#service httpd restart

# add symbolic link to default dir
#echo Adding a symlink to /var/www_symlinks for broadcasting
#ln -s /home/adrian/Workspace/${DOMAIN}/public/ /var/www_symlinks/${DOMAIN}

#echo "Complete\c"
#read NOTHING










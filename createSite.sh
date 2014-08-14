#!/bin/bash

#################################
# SETTINGS LOCATIONS
WWW_ROOT='/var/www' # no trailing slash
DOC_ROOT='httd_docs' # no trailing slash

# SETTINGS TEMPLATE FILE
INDEX_MSG='HOSTING READY FOR <DN>' # <DN> WILL BE REPLACED WITH THE DOMAIN
INDEX_FILE='index.html'

# SETTINGS DIRECTORY PERMISSIONS
DIR_OWNER='apache'
DIR_GROUP='apache'
DIR_MOD='770'

# APACHE
APACHE_RELOAD='service httpd reload' # cmd to restart apache
APACHE_CONF_LOCATION='/etc/httpd/conf.d' # no trailing slash
APACHE_CONF_TEMPLATE="
# <FQDN>
<VirtualHost *:80>
    ServerAdmin webmaster@<DN>
    ServerName <FQDN>
    ServerAlias <DN>

    RewriteEngine on 
    rewritecond %{http_host} \"!^<FQDN>\" [nc]
    rewriterule ^(.*)$ http://<FQDN>/\$1 [r=301,nc

    Options Indexes FollowSymLinks Multivews
    AllowOverride All
    Order allow,deny
    allow from all

    DocumentRoot <DN_ROOT>
    ErrorLog /var/log/httpd/<FQDN>-apache-error_log
    CustomLog /var/log/httpd/<FQDN>-access_log common
</VirtualHost>"; # <DN> WILL BE REPLACED WITH THE DOMAIN, DN_ROOT WITH DOCUMENT ROOT AND FQDN WITH THE FQDN
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
	# GET DN AND FQDN
	notice "Please enter the domain name"
	read DN
	DN="${DN/#\www./}"
	FQDN="www.$DN"
	
	# BEGIN 
	host $DN 2>&1 > /dev/null
	if [ ! $? -eq 0 ]; then
		echo "$DN is not valid domain"
	else
		DN_SLUG=$(slugify "$DN");
		if [ -d "$WWW_ROOT/$DN_SLUG" ]; then
			notice "$DN already exists in $WWW_ROOT/$DN_SLUG"
		else	
			# MAIN STRUCTURE
			mkdir "$WWW_ROOT/$DN_SLUG"
			mkdir "$WWW_ROOT/$DN_SLUG/$DOC_ROOT"
			echo "${INDEX_MSG//<DN>/$FQDN}" > "$WWW_ROOT/$DN_SLUG/$DOC_ROOT/$INDEX_FILE"

			# OWNERSHIP
			chown -R "$DIR_OWNER:$DIR_GROUP" "$WWW_ROOT/$DN_SLUG"
			chmod -R "$DIR_MOD" "$WWW_ROOT/$DN_SLUG"

			# QUICK LOOK UP LOCALLY
			echo 127.0.0.1   ${DN} >> /etc/hosts
			echo 127.0.0.1   ${FQDN} >> /etc/hosts

			# APACHE ENTRIES
			APACHE_TEMPLATE="${APACHE_CONF_TEMPLATE//<DN>/$DN}";
			APACHE_TEMPLATE="${APACHE_TEMPLATE//<FQDN>/$FQDN}";
			APACHE_TEMPLATE="${APACHE_TEMPLATE//<DN_ROOT>/$WWW_ROOT/$DN_SLUG/$DOC_ROOT/}";
			echo "$APACHE_TEMPLATE" > "$APACHE_CONF_LOCATION/$DN_SLUG";
			$APACHE_RELOAD;
			# FIN
			notice "$DN created at $WWW_ROOT/$DN_SLUG"
				
		fi
	fi

fi
read STOP
exit;
################################



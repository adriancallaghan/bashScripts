#!/bin/bash

#################################
# SETTINGS LOCATIONS
WWW_ROOT='/var/www' # no trailing slash
DOC_ROOT='httd_docs' # no trailing slash

# SETTINGS TEMPLATE FILE
INDEX_MSG='HOSTING READY FOR <DN>' # <DN> WILL BE REPLACED WITH THE DOMAIN
INDEX_FILE='index.html'

# SETTINGS DIRECTORY PERMISSIONS
DIR_OWNER='www-data'
DIR_GROUP='www-data'
DIR_MOD='777'

# APACHE (UBUNTU)
APACHE_ENABLE="a2ensite " # cmd to enable
APACHE_RELOAD='service apache2 reload' # cmd to reload/restart apache
APACHE_CONF_LOCATION='/etc/apache2/sites-available/' # no trailing slash
APACHE_CONF_TEMPLATE="
# <FQDN>
<VirtualHost *:80>
    ServerAdmin webmaster@<DN>
    ServerName <FQDN>
    ServerAlias <DN>

    DocumentRoot <DN_ROOT>
    ErrorLog /var/log/apache2/<DN_SLUG>-apache-error_log
    CustomLog /var/log/apache2/<DN_SLUG>-access_log common
</VirtualHost>"; # <DN> WILL BE REPLACED WITH THE DOMAIN, FQDN WITH THE FQDN, DN_SLUG WITH THE DOMAIN SLUG AND DN_ROOT WITH DOCUMENT ROOT

# HOSTS FILE
HOSTS_FILE='/etc/hosts'
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
	#if [ ! $? -eq 0 ]; then
	#	echo "$DN is not valid domain"
	#else
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
			HOSTS_FILE_BK="$(date +$HOSTS_FILE-%d%m%Y_%R.bak)";
			cp "$HOSTS_FILE" "$HOSTS_FILE_BK";
			if [ ! -f "$HOSTS_FILE_BK" ]; then
				notice "Failed to create host file backup at $HOSTS_FILE_BK"
			else 

				echo "# ${FQDN}" >> "$HOSTS_FILE";
				echo 127.0.0.1   ${DN} >> "$HOSTS_FILE";
				echo 127.0.0.1   ${FQDN} >> ""$HOSTS_FILE"";

				# APACHE ENTRIES
				APACHE_TEMPLATE="${APACHE_CONF_TEMPLATE//<DN>/$DN}";
				APACHE_TEMPLATE="${APACHE_TEMPLATE//<FQDN>/$FQDN}";
				APACHE_TEMPLATE="${APACHE_TEMPLATE//<DN_ROOT>/$WWW_ROOT/$DN_SLUG/$DOC_ROOT/}";
				APACHE_TEMPLATE="${APACHE_TEMPLATE//<DN_SLUG>/$DN_SLUG}";
		
				echo "$APACHE_TEMPLATE" >> "${APACHE_CONF_LOCATION}/${DN_SLUG}.conf";
                                $APACHE_ENABLE "$DN_SLUG";
				$APACHE_RELOAD;
				notice "$DN created at $WWW_ROOT/$DN_SLUG"
				
			fi
		fi
	#fi

fi
read STOP
exit;
################################


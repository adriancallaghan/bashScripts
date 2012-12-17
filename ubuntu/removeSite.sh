echo off
cd /home/adrian/Workspace/
clear
echo 
echo Projects are:
echo 
ls 
echo 
echo "Please enter the project name to remove \c"
read PROJECT

if [ ! -d "${PROJECT}" ]; then
     	echo Invalid project name ${PROJECT}
	read NOTHING
	exit
fi

echo "Are you sure you wish to delete ${PROJECT} (y/n) \c"
read CONFIRM

if [ ! "${CONFIRM}" = 'y' ]; then
	echo "...Aborted"
	read NOTHING
	exit
fi

echo "Disabling site in Apache ${PROJECT}"
# disable by using INBUILT command 
a2dissite ${PROJECT}.localhost


# restart apache
echo Restarting apache
apache2ctl restart

# remove hosts
echo "Removing site v-host"
rm /etc/apache2/sites-available/${PROJECT}.localhost


# archive site
echo "Moving ${PROJECT} to /home/adrian/sites_archived/${PROJECT}"
mv ${PROJECT} /home/adrian/sites_archived/
cd /home/adrian/sites_archived/
echo "Compressing ${PROJECT}"
tar -cvzf ${PROJECT}.tar.gz ${PROJECT}
echo "Deleting site, preserving compressed file"
rm -r ${PROJECT} 


# removing entry in hosts file
echo Removing ${PROJECT}.localhost from local hosts file
sed /"127.0.0.1 www.${PROJECT}.localhost"/d /etc/hosts > /etc/hosts.tmp1
sed /"127.0.0.1 ${PROJECT}.localhost"/d /etc/hosts.tmp1 > /etc/hosts.tmp2
rm /etc/hosts.tmp1
echo "creating hosts backup /etc/hosts.bkup"
mv /etc/hosts /etc/hosts.bkup
mv /etc/hosts.tmp2 /etc/hosts
echo "Hosts updated"
echo
echo

# removing sym link from defaults
echo removing symlink
rm /var/www_symlinks/${PROJECT}

echo -e "Complete\c"
read NOTHING










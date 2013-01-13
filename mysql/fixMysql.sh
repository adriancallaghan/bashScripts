


# move to mysql folder
cd /var/lib/mysql/


# create the task list
ls -d */ > fix_list



for i in `cat fix_list`;
do
	myisamchk -r ${i}/*.MYI
done


rm fix_list

/etc/init.d/mysql restart


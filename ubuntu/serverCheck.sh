#!/bin/bash
# ---------------------------------------------------------------
# DESCRIPTION:
# Restart servers Apache/mysql if they go down and let me know
# Adrian Callaghan 250410
# ---------------------------------------------------------------


# ---------------------------------------------------------------
# SETTINGS:
#
# SERVERS
#servers=(apache2)
servers=(apache2 mysql)
#
#
# LOG FILE
LOG=/var/log/serverlog.txt
#
# ---------------------------------------------------------------




# ---------------------------------------------------------------
# CODE:
#
#
# LOOP THROUGH SERVERS CHECKING THERE RUNNING
for i in ${servers[@]}; do

        # Find server pid
        NULL=$(/usr/bin/pgrep ${i})


        if [ $? -ne 0 ] # if server not running
        then
                # Log the event
                echo CRASHED ${i} $(date) >> ${LOG}

                # Attempt a restart
                /etc/init.d/${i} restart 

                # The existence of a file, acts a boolean to not trigger an email, ie if the file exists dont email as the status
                # has not changed since the last check, becuase it would have been created when the last notification email was sent
                # no other action is required if it exists as the server will have already created the log, and will just keep
                # trying to restart, until this is successfull the file will remain inhibiting any further notification duplications
                if [ ! -f $i ]; then
                        
                        #echo creating 
                        # create the file that locks the state saying there is a problem.
                        echo LOCKED > $i

                        # and mail
                        echo ${i} is down $(date) > temp.txt
                        #mailx -s "Charlie server" "admin@adriancallaghan.co.uk" < temp.txt
                        rm temp.txt
                fi



        else
                # Here the server has been detected as running..... so do nothng!
                # ....But!
                # if the server was not running before, a file will exist that stops multiple notifictaions of repeated restart attempts
                # detect this, mail to say everything is fine, and remove the file

                if [ -f $i ]; then
                
                        # remove the file that locks the state saying there is a problem.
                        rm $i

                        # and mail to say its running again
                        echo ${i} is running $(date) > temp.txt
                        #mailx -s "Charlie server" "admin@adriancallaghan.co.uk" < temp.txt
                        rm temp.txt

                        # Log the event
                        echo RUNNING ${i} $(date) >> ${LOG}
                fi
                
                echo ${i}: Running
        fi

done

exit


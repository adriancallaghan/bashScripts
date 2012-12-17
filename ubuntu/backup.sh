# BACKUP_FROM = BASE LOCATION OF THE DIRECTORIES TO BACKUP 
BACKUP_FROM=/var/www/sites/

# BACKUP_TO = BASE LOCATION OF THE DESTINATION (HAS TODAYS DATE APPENDED) 
BACKUP_TO=/home/backups/BKUP_$(date +%d%m%y)

# Name of the file from one month ago, if this exists it will be deleted automatically
ONE_MONTH_BEFORE=/home/backups/BKUP_$(date -d"3 week ago" "+%d%m%y")

# LOG FILES
LOG=${BACKUP_TO}/log.txt
TARLOG=${BACKUP_TO}/tar_log.txt

# check for existence of the folder
if [ -d $BACKUP_TO ]; then 
        echo -- !! ERROR !! -- >> ${LOG}
        echo ${BACKUP_TO} directory already exists >> ${LOG}
        echo -- !! HALTED !! -- >> ${LOG}
        # some visual feedback
        cat $LOG
        exit;
else
        #echo Creating directory ${BACKUP_TO} >> ${LOG}
        mkdir ${BACKUP_TO}
        #echo Beginning back up @ $(date) >> ${LOG}
        # check for the existence of the folder
        if [ ! -d $BACKUP_TO ]; then
                echo Failed to create ${BACKUP_TO} directory >> ${LOG}
                # some visual feedback
                cat $LOG
        exit;
        else
                echo Folder ${BACKUP_TO} created succesfully >> ${LOG}
        fi
fi

# create the task list
cd ${BACKUP_FROM}
ls -d */ > ${BACKUP_TO}/backup_todo




# do the backup
if [ ! -f ${BACKUP_TO}/backup_todo ]; then
        echo -- !! ERROR !! -- >> ${LOG}
        echo Failed to access to do list: ${BACKUP_TO}/backup_todo >> ${LOG}
        echo -- !! HALTED !! -- >> ${LOG}
        # some visual feedback
        cat $LOG
        exit;
else
        echo BACKUPS TODO: >> ${LOG}
        cat ${BACKUP_TO}/backup_todo >> ${LOG}
fi


for i in `cat ${BACKUP_TO}/backup_todo`;
do
        if [ -d ${BACKUP_FROM}${i} ]; then
                tar -cvzf ${BACKUP_TO}/${i%/}.tar.gz ${BACKUP_FROM}${i}  >> ${TARLOG};
                if [ ! -f ${BACKUP_TO}/${i%/}.tar.gz  ]; then
                        echo Failed to backup:  From: ${BACKUP_FROM}${i} To: ${BACKUP_TO}/${i%/}.tar.gz >> ${LOG}
                else
                        echo Succesfully backed up:  From: ${BACKUP_FROM}${i} To: ${BACKUP_TO}/${i%/}.tar.gz >> ${LOG}
                fi 
        else
                echo Source file: ${BACKUP_FROM}${i} does not exist cannot create backup >> ${LOG}
        fi
done


# protect
echo Protecting ${BACKUP_TO} >> ${LOG}
chmod 700 -R $BACKUP_TO


# clean up from last month
if [ -d $ONE_MONTH_BEFORE ]; then 
        echo Found a previous months backup: ${ONE_MONTH_BEFORE} >> ${LOG}
        rm -r -f $ONE_MONTH_BEFORE
        if [ -d $ONE_MONTH_BEFORE]; then
                echo Failed to delete ${ONE_MONTH_BEFORE} >> ${LOG}
        else
            echo Successfully deleted ${ONE_MONTH_BEFORE} >> ${LOG}
        fi
else
        echo Previous months backup not found >> ${LOG}
fi



echo !! COMPLETED @ $(date) !! >> ${LOG}
echo ----------------------------------------------- >> ${LOG}




# some visual feedback
#cat $LOG
#mailx -s "Cron report from Charlie" admin@adriancallaghan.co.uk < $LOG
exit;




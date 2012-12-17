mysqldump -uUSERNAME -pPASSWORD --all-databases | gzip > /backups/database_$(date +%d%m%y).sql.gz


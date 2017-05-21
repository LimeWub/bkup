# ----------------------------------------------------------------------
# Clean up old bkups script (rotate)
# ----------------------------------------------------------------------

#Delete all bkup folders over the limit+ for Code and SQL 
c=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d  -print | grep "/BACKUP_"| wc -l )
BKUPS_TODELETE_COUNT=`expr $c - $BKUP_DAYSTOKEEP `
c=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/SQLBACKUP_"| wc -l )
SQL_TODELETE_COUNT=`expr $c - $BKUP_DAYSTOKEEP`

if [ "$BKUPS_TODELETE_COUNT" -gt 0 ]
then
	find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/BACKUP_" | sort | head -"$BKUPS_TODELETE_COUNT" | while IFS= read -r  dir 
	do 
			if [ "$v" == "true" ]; then echo "DELETING unneeded old backup $dir"; fi
			rm -rf  "$dir"
	done
fi

if [ "$SQL_TODELETE_COUNT" -gt 0 ]
then
	find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/SQLBACKUP_" | sort | head -"$SQL_TODELETE_COUNT" | while IFS= read -r  dir 
	do 
			if [ "$v" == "true" ]; then echo "DELETING unneeded old backup $dir"; fi
			rm -rf  "$dir"
	done
fi
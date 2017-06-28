#!/bin/bash

#Password security
OPTFILE=$(mktemp -q tmp.XXXXXX)
chmod 0600 "$OPTFILE"
cat >"$OPTFILE" <<EOF
[client]
password="${DB_PASS}"
EOF

SAVEDIR="$BKUP_HOLDERDIR/$SQL_DIR/"
#If older MySQL backup, make hard copy of it.
if [ -d "$SQL_PREVDIR" ]
then
	if [ "$v" == "true" ]; then echo "Copying (hard link) from '$SQL_PREVDIR' to '$BKUP_HOLDERDIR/$SQL_DIR'"; fi
	#Generate initial hard link "copy"
	find "$SQL_PREVDIR" -mindepth 1 -depth -type d -print0| while IFS= read -r -d $'\0' dir
		do mkdir -p "$BKUP_HOLDERDIR/$SQL_DIR${dir/$SQL_PREVDIR/}"
	done


	find "$SQL_PREVDIR" -type f -print0| while IFS= read -r -d $'\0' file
		do ln "$file" "$BKUP_HOLDERDIR/$SQL_DIR${file/$SQL_PREVDIR/}";
	done
	# < GRUMP! > If using a decent OS that's not limited af (aka not a OSX) the below will probably also work</ GRUMP!  > 
	# cp -al "$BKUP_PREVDIR" "$BKUP_HOLDERDIR/$SQL_DIR"

T_SAVEDIR="$SAVEDIR" #Keep correct SAVEDIR stored under different named var. (for Rsync)
SAVEDIR="$BKUP_HOLDERDIR/TEMP/$SQL_DIR/" #Change SAVEDIR to TEMP one.
fi

#Do DB DUMP in a temporary folder instead
DBS=$(mysql  --defaults-extra-file="$OPTFILE" -u$DB_USER -h$DB_HOST -Bse 'show databases')
for DB in $DBS
do
	if [ "$DB" != "information_schema" ] && [ "$DB" != "mysql" ] #ignore info scema, mysql
	then
		SAVELOCATION="$SAVEDIR$DB"
		[ -d "$SAVELOCATION" ] || mkdir -p "$SAVELOCATION"

		if [ "$v" == "true" ]; then echo "----------START DB TABLE DUMP-------------"; fi
		if [ "$v" == "true" ]; then echo "Dumping tables into separate SQL command files for database '$DB' into dir=$SAVELOCATION"; fi

		tbl_count=0
		for t in $(mysql --defaults-extra-file="$OPTFILE" -NBA -h$DB_HOST -u$DB_USER -D$DB -e 'show tables') 
		do 
			if [ "$v" == "true" ]; then echo "DUMPING TABLE: $DB.$t"; fi
			#do we want to gzip them? hmmm
			mysqldump --defaults-extra-file="$OPTFILE" --skip-dump-date -h$DB_HOST -u$DB_USER $DB $t > $SAVELOCATION/$DB.$t.sql
			tbl_count=$(( tbl_count + 1 ))
		done

		if [ "$v" == "true" ]; then echo "$tbl_count tables dumped from database '$DB' into dir=$SAVELOCATION"; fi
		if [ "$v" == "true" ]; then echo "----------END DB TABLES DUMP-------------"; fi
		

	fi
done

#Rsync over and delete TMP if exists
if [ -d "$SQL_PREVDIR" ] && [ -d "$T_SAVEDIR" ]
then
	if [ "$v" == "true" ]; then echo "----------RSYNC/DELETE of TEMPorary files-------------"; fi
	if [ "$v" == "true" ]; then echo "Syncing from $SAVEDIR to $T_SAVEDIR."; fi
	if [ "$v" == "true" ]; then echo "Deleting from $SAVEDIR."; fi
	if [ "$v" == "true" ]; then echo "~Goodnight sweet prince~"; fi
	if [ "$v" == "true" ]; then echo "----------END RSYNC/DELETE of TEMPorary files-------------"; fi
	rsync -ah  --checksum --delete "$SAVEDIR" "$T_SAVEDIR" #force checksum and ignoretimes
	rm -rf "$SAVEDIR"
fi

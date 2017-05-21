#!/bin/bash

# ----------------------------------------------------------------------
#
# Author: Myrto C Kontouli
# 999Design.com
# Date: 18/May/2017
#
# ----------------------------------------------------------------------
#
# Backup wrapper/handler
#
# Backs up target directory and its contents, as well as whole of target database, in an incremental manner.
# Settings for directories and databases are in this file.
# Uses hard links to save space.
# Makes use of tmp files which are deleted at end of execution.
# Emails your preferred email at the end of completion.
#
#
# ----------------------------------------------------------------------
# Options
#
#  -v            Verbose output
#
# ----------------------------------------------------------------------
#
# Notices!
# *** REPLACE PLACEHOLDER_* WITH THE DIRECTORIES/DATABASE DETAILS YOU WANT TO TARGET
# *** CURRENTLY ONLY LOCAL FOLDER BACKING UP IS SUPPORTED!
#
# ----------------------------------------------------------------------

# Move to directory where the script is at. 
# This is added to make it possible to summon the script from a different path and still have the sources etc work properly ( even when relative).
cd "$(dirname "${BASH_SOURCE[0]}")"

#Clean up tmp files end of script
trap "rm -f tmp.*" EXIT

#Myrto: make it log the echoes to tmp.
OUTPUT_TMP=$(mktemp -q tmp.XXXXXX)
chmod 0600 "$OUTPUT_TMP"
exec &> "$OUTPUT_TMP"


echo ""
echo "----------BACKUP STARTED on $(date +%Y-%m-%d_%T)-------------"

while getopts ":v" opt
do
	case $opt in
		v)
			v=true
			echo "-v was triggered"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit
			;;
	esac
done

#Set bkup directory
BKUP_HOLDERDIR="PLACEHOLDER_BACKUPHOLDERDIR"

#Set codebase settings
SOURCE_HOLDERDIR="PLACEHOLDER_SOURCEHOLDERDIR"
BKUP_PREVDIR=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/BACKUP_" | sort | tail -1)
BKUP_DIR="BACKUP_$(date +%Y%m%d_%A_%s)";
#Set ignore files/folders matching *list*

#Set db settings
DB_HOST="PLACEHOLDER_DBHOSTIP"
DB_USER="PLACEHOLDER_DBUSER"
DB_PASS="PLACEHOLDER_DBPASS"
SQL_PREVDIR=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/SQLBACKUP_" | sort | tail -1)
SQL_DIR="SQLBACKUP_$(date +%Y%m%d_%A_%s)";

#How many days of bkups do we want to keep? 10?
BKUP_DAYSTOKEEP=10



#Backup files
source ./bkup_code.sh

#Backup databases
source ./bkup_databases.sh

#Rotate backups
source ./bkup_rotation.sh



echo "----------BACKUP COMPLETED on $(date +%Y-%m-%d_%T)-------------"
echo ""


#LOG append and EMAIL
LOG_FILE="bkup.log"
[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
cat "$OUTPUT_TMP" >> "$LOG_FILE"

cat "$OUTPUT_TMP" | mail -s "[$(hostname)] BACKUP RUN $(date +%A)" PLACEHOLDER_YOUREMAILADDRESS@EMAIL.com
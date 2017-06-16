#!/bin/bash

# ----------------------------------------------------------------------
#
# Author: Myrto C Kontouli
# 999Design.com
# Date: 18/May/2017
# Last Updated: 17/June/2017
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



set -e  # Temporary error handling. (Quit script on error)

# Move to directory where the script is at. 
# This is added to make it possible to summon the script from a different path and still have the sources etc work properly ( even when relative).
cd "$(dirname "${BASH_SOURCE[0]}")"

#Myrto: make it log the echoes to tmp.
OUTPUT_TMP=$(mktemp -q tmp.XXXXXX)
chmod 0600 "$OUTPUT_TMP"
#exec &> "$OUTPUT_TMP"


#Emailer
out2email() {
	if [ ! -z "$CONTACT_EMAIL" ]
	then
		cat "$OUTPUT_TMP" | mail -s "[$(hostname)] BACKUP RUN $(date +%A)" "$CONTACT_EMAIL"
	fi
}

#Backtrace generator
#Creds: https://stackoverflow.com/q/5811002
backtrace () {
	echo "Backtrace is:"
	i=1
	while caller $i
	do
		i=$((i+1))
	done
}

#Error reporting handling
#Creds: https://stackoverflow.com/a/185900
error() {
	local message="$1"
	local code="${2:-1}"
	if [[ -n "$message" ]] ; then
		echo "Error! ${message} Exiting with status ${code}"
		backtrace
	else
		echo "Error! Exiting with status ${code}"
		backtrace
	fi

	echo "----------BACKUP EXITED WITH ERROR on $(date +%Y-%m-%d_%T)-------------"
	echo ""

	exit "${code}"
}

finish() {

	#LOG append
	LOG_FILE="bkup.log"
	[ -f "$LOG_FILE" ] || touch "$LOG_FILE"
	cat "$OUTPUT_TMP" >> "$LOG_FILE"

	#send email
	out2email

	#Clean up tmp files end of script
	rm -f tmp.*
}

set +e #  End of: Temporary error handling.

trap finish EXIT
trap error ERR



#!!!!!!
#------------- ERROR REPORTING ACTIVE HERE ON OUT! -------------
#!!!!!!



echo ""
echo "----------BACKUP STARTED on $(date +%Y-%m-%d_%T)-------------"

#Set up settings
source ./bkup_settings.sh


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



#Backup files
source ./bkup_code.sh

if [ -z "$NODB_SWITCH" ]
then
	#Backup databases
	source ./bkup_databases.sh
fi

#Rotate backups
source ./bkup_rotation.sh


echo "----------BACKUP COMPLETED on $(date +%Y-%m-%d_%T)-------------"
echo ""
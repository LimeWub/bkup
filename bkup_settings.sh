#!/bin/bash

# ----------------------------------------------------------------------
#
# Uncomment settings to match your setup.
# Make sure all *REQUIRED* variables are filled out appropriately before running the script.
#
# ----------------------------------------------------------------------
#
# Notices!
# *** REPLACE PLACEHOLDER_* WITH THE DIRECTORIES/DATABASE DETAILS YOU WANT TO TARGET
#
#
# ----------------------------------------------------------------------

#Set contact email
#**# CONTACT_EMAIL = "PLACEHOLDER_YOUREMAILADDRESS@EMAIL.com"

#Set bkup directory
#*REQUIRED*# BKUP_HOLDERDIR="PLACEHOLDER_BACKUPHOLDERDIR"

#Set codebase settings
#**# SERVER_HOST = "PLACEHOLDER_SERVERHOST"
#**# SERVER_USER = "PLACEHOLDER_SERVERUSER"
#**# SERVER_PASS = "PLACEHOLDER_SERVERPASS"
#*REQUIRED*# SOURCE_HOLDERDIR="PLACEHOLDER_SOURCEHOLDERDIR"
BKUP_PREVDIR=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/BACKUP_" | sort | tail -1)
BKUP_DIR="BACKUP_$(date +%Y%m%d_%A_%s)";

#TODO: Set ignore files/folders matching *list*

#Set db settings
#**# DB_HOST="PLACEHOLDER_DBHOSTIP"
#**# DB_USER="PLACEHOLDER_DBUSER"
#**# DB_PASS="PLACEHOLDER_DBPASS"
SQL_PREVDIR=$(find "$BKUP_HOLDERDIR" -maxdepth 1 -type d -print | grep "/SQLBACKUP_" | sort | tail -1)
SQL_DIR="SQLBACKUP_$(date +%Y%m%d_%A_%s)";

#How many days of bkups do we want to keep? 10?
BKUP_DAYSTOKEEP=10

if [ ! -d "$BKUP_HOLDERDIR" ] || [ -z "$SOURCE_HOLDERDIR" ] 
then
	error "[Settings] BACKUP OR SOURCE DIRECTORIES NOT SPECIFIED!"
fi


if [[ ( -z "$DB_HOST"  ||  "$DB_HOSTxxx" = "xxx" )  || ( -z "$DB_USER"  ||   "$DB_USERxxx" = "xxx" ) || ( -z "$DB_PASS"  ||   "$DB_PASSxxx" = "xxx" ) ]]
then
	NODB_SWITCH="ON"
fi


#if we have no SERVER_USER or we have no SERVER_PASS or we have no SERVER_HOST assume localhost Rsync
if [[ ( -z "$SERVER_HOST"  ||  "$SERVER_HOSTxxx" = "xxx" )  || ( -z "$SERVER_USER"  ||   "$SERVER_USERxxx" = "xxx" ) || ( -z "$SERVER_PASS"  ||   "$SERVER_PASSxxx" = "xxx" ) ]]
then
	LOCALHOST_SWITCH="ON"
fi
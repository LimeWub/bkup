#!/bin/bash

# ----------------------------------------------------------------------
# Idea for bkup script:
# ----------------------------------------------------------------------
if [ "$v" == "true" ]; then echo "----------START CODE BACKUP-------------"; fi

### < GRUMP! >This would have literally been a one line thing, if my tools were working as expected.
###For reasons unknown, rsync actually refuses to handle the link-dest parameter properly. </ GRUMP!  > (***)
###Rsync whole backup folder into the bkup directory (link-dest should handle hard links)
###OPT="-avh -e `ssh -p 2346` --link-dest=$LNK"
#OPT="-avuh --link-dest=$BKUP_PREVDIR"
#rsync "$OPT" "$SOURCE_HOLDERDIR" "$BKUP_HOLDERDIR/$BKUP_DIR"

#(***) Hence, lets try the good ol' way of doing this.
if [ -d "$BKUP_PREVDIR" ]
then
	if [ "$v" == "true" ]; then echo "Copying (hard link) from '$BKUP_PREVDIR' to '$BKUP_HOLDERDIR/$BKUP_DIR'"; fi
	#Generate initial hard link "copy"
	find "$BKUP_PREVDIR" -mindepth 1 -depth -type d -print0| while IFS= read -r -d $'\0' dir
		do mkdir -p "$BKUP_HOLDERDIR/$BKUP_DIR${dir/$BKUP_PREVDIR/}"
	done


	find "$BKUP_PREVDIR" -type f -print0| while IFS= read -r -d $'\0' file
		do ln "$file" "$BKUP_HOLDERDIR/$BKUP_DIR${file/$BKUP_PREVDIR/}";
	done
	# < GRUMP! > If using a decent OS that's not limited af (aka not a OSX) the below will probably also work</ GRUMP!  > 
	# cp -al "$BKUP_PREVDIR" "$BKUP_HOLDERDIR/$BKUP_DIR"
fi

if [ "$v" == "true" ]; then echo "Sync from '$SOURCE_HOLDERDIR' to '$BKUP_HOLDERDIR/$BKUP_DIR'"; fi



if [ -z "$LOCALHOST_SWITCH" ]
then
	expect <<END
	#if is remote server
	set timeout -1
	spawn rsync -auh -e ssh --delete "$SERVER_USER@$SERVER_HOST:$SOURCE_HOLDERDIR" "$BKUP_HOLDERDIR/$BKUP_DIR"
	expect "password:"
	send "$SERVER_PASS\r"
	expect eof
END

else
	#if this is localhost
	rsync -auh --delete "$SOURCE_HOLDERDIR" "$BKUP_HOLDERDIR/$BKUP_DIR"

fi




if [ "$v" == "true" ]; then echo "----------END CODE BACKUP-------------"; fi
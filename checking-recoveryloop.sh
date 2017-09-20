#!/bin/bash
#
# automated Juniper blackhole routing checking and send recovery   
# author - patrick ong, ongtiongheng@gmail.com
# date - 2016 Oct 6th
#
arg1=$1
DATE=`date +%Y-%m-%d`
session_id=`head -c4 /dev/urandom | od -N4 -tu4 | sed -ne '1s/.* //p'`
_file=$arg1.check
arg_jump1[0]="TIER1_JUMPBOX_SVR1"
arg_jump1[1]="TIER1_JUMPBOX_SVR2"
arg_jump2[0]="TIER2_JUMPBOX_SVR1"
arg_jump2[1]="TIER2_JUMPBOX_SVR2"
rand_j1=$[$RANDOM % 2]
rand_j2=$[$RANDOM % 2]
rand_preempt1=$[$RANDOM % 2 + 1]
rand_preempt2=`/usr/bin/od -vAn -N2 -tu2 < /dev/urandom`

# Random Sleep to async the attempts
/bin/sleep 0.$(($rand_preempt2-$rand_preempt1))

[ ! -f "$_file" ] && { echo "Error: $0 file not found."; exit 2; }
 
if [ -f "$_file" ]
then
   echo "$_file exists"
   ( 
	# find_push.exp requires 3 arguments, jump1, jump2 and host
	#
	/usr/bin/expect find_push.exp ${arg_jump1[$rand_j1]} ${arg_jump2[$rand_j2]} $arg1 > $session_id

	#toggle for testing - please set properly to work
	# 
	#TESTING -/bin/grep Push found | /bin/grep -v "\"Push\|\\\\\*"
	# annotation , the above -v ignore the Push keyword from the command itself
	#
	# filter out binary file false positive 
	/usr/bin/strings $session_id > $arg1-$DATE-CHECK-$session_id.txt 
	/bin/grep Push $arg1-$DATE-CHECK-$session_id.txt | /bin/grep -v "\"Push\|\\\\\*"
	greprc=$?
	if [[ $greprc -eq 0 ]] ; then
	    echo Found
	    /bin/rm $arg1-$DATE-CHECK-$session_id.txt
	else
	    if [[ $greprc -eq 1 ]] ; then
	       echo Not found
	       /bin/bash sendmail-sendrecovery.sh $arg1
	       /bin/bash sendsms.sh $arg1 NORMAL
	       /bin/rm $_file
	    else
		echo Some sort of error
	    fi
	fi
	/bin/rm $session_id
   )
else
    echo "$_file is empty."
    # do something as file is empty
fi

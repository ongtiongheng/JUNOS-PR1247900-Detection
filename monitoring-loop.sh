#!/bin/bash
#
# automated Juniper blackhole routing detection and self-healing   
# author - patrick ong, ongtiongheng@gmail.com
# date - 2016 Oct 6th
#
arg1=$1
DATE=`date +%Y-%m-%d`
session_id=`head -c4 /dev/urandom | od -N4 -tu4 | sed -ne '1s/.* //p'`
arg_jump1[0]="tier1-jumpbox-svr1"
arg_jump1[1]="tier1-jumpbox-svr1"
arg_jump2[0]="tier2-jumpbox-svr2"
arg_jump2[1]="tier2-jumpbox-svr2"
rand_j1=$[$RANDOM % 2]
rand_j2=$[$RANDOM % 2]
rand_preempt1=$[$RANDOM % 2 + 1]
rand_preempt2=`/usr/bin/od -vAn -N2 -tu2 < /dev/urandom`

# Random Sleep to async the attempts
/bin/sleep 0.$(($rand_preempt2-$rand_preempt1))

# find_push.exp requires 3 arguments, jump1, jump2 and host
#
/usr/bin/expect find_push.exp ${arg_jump1[$rand_j1]} ${arg_jump2[$rand_j2]} $arg1 > $session_id

#toggle for testing - please set properly to work
# 
#TESTING -/bin/grep Push found | /bin/grep -v "\"Push\|\\\\\*"
# annotation , the above -v ignore the Push keyword from the command itself
#
# filter out binary file false positive 
/usr/bin/strings $session_id > $arg1-$DATE-PUSH-$session_id.txt 
/bin/grep Push $arg1-$DATE-PUSH-$session_id.txt | /bin/grep -v "\"Push\|\\\\\*"
greprc=$?
if [[ $greprc -eq 0 ]] ; then
    echo Found
    /bin/bash sendmail.sh $arg1 $session_id
    /bin/bash sendsms.sh $arg1 CRITICAL
    /bin/touch $arg1.check
else
    if [[ $greprc -eq 1 ]] ; then
        echo Not found
    else
        echo Some sort of error
    fi
    /bin/rm $arg1-$DATE-PUSH-$session_id.txt
fi
/bin/rm $session_id

#!/bin/bash 
#
# warning - private stuff here do not copy and paste
# using visualgsm enterpise sms appliance to send out SMS.
#
# contact list - spongebob, patrick, squidward, MrKrab, Sandy handphones
# argument - 1st, routername ; 2nd, known_status
#
# changelog - add arg2
#
arg1=$1
arg2=$2
DATE=`date +%Y-%m-%d`
serverlist[0]="YOUR_SMTP_RELAY_SVR1"
serverlist[1]="YOUR_BACKUP_SMTP_RELAY_SVR2"
rand=$[$RANDOM % 2]
#
   echo "$arg1 has some data."
   ( 
        sleep 1 
        echo helo a 
        sleep 1 
        echo mail from:\<\> 
        sleep 1 
        echo rcpt to:12345678@visualgsm.ntt.com.sg
        sleep 1 
        echo rcpt to:23456789@visualgsm.ntt.com.sg
        sleep 1 
        echo rcpt to:34567890@visualgsm.ntt.com.sg
        sleep 1 
        echo rcpt to:45678901@visualgsm.ntt.com.sg
        sleep 1 
        echo rcpt to:56789012@visualgsm.ntt.com.sg
        sleep 1 
        echo data 
	echo "Subject: [$arg2] INET_LSP-at-$arg1" 
        sleep 1 
        echo ####
        echo . 
        echo quit
   ) | telnet ${serverlist[$rand]} 25

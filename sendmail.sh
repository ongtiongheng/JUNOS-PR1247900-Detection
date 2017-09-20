#!/bin/bash 
#
# This script is send out the router dump pertaining to the prefixes being blackholes.
#
# arg1 = router ip address/hostname
# arg2 = dump file for attachment
#
arg1=$1
arg2=$2
_file=$arg2
myfile=`cat $arg2 | /usr/bin/openssl base64`
DATE=`date +%T`
serverlist[0]="YOUR_SMTP_RELAY_SVR1"
serverlist[1]="YOUR_BACKUP_SMTP_RELAY_SVR2"
rand=$[$RANDOM % 2]
#[ $# -eq 0 ] && { echo "Usage: $0 filename"; exit 1; }
[ ! -f "$_file" ] && { echo "Error: $0 file not found."; exit 2; }
 
if [ -s "$_file" ]
then
   echo "$_file has some data."
   ( 
        sleep 1 
        echo helo a 
        sleep 1 
        echo mail from:\<\> 
        sleep 1 
        echo rcpt to:helpdesk@your_domain.fqdn.com
        sleep 1 
        echo rcpt to:yourself@your_domain.fqdn.com
        sleep 1 
        echo data 
        echo "From: Nagios@your_domain.fqdn.com"
        echo "To: Helpdesk@your_domain.fqdn.com"
	echo "MIME-Version: 1.0" 
	echo "Subject: [CRITICAL] $DATE Alert ~ your_domain.fqdn.com $arg1 has LSP-RSVP routing blackholes" 
	echo "From: $from"
	echo "To: patrick.ong@your_domain.fqdn.com"
	echo "Content-Type: multipart/mixed; boundary=sep"
        echo "X-Priority: 1 (Highest)"
        echo "X-MSMail-Priority: High"
	echo "--sep"
	echo "Content-Type: text/plain; charset=UTF-8"
        echo ####
	echo "BB router routes that exhibits push state, run - commit full / clear mpls lsp"
        echo ""
        echo "Find diagnostic info for $arg1 below:"
        echo ""
	echo "Action item: Call Your Engineering team"
        echo ""
	echo "--sep" 
	echo "Content--Type: text/x-log; name=\"mytest.log\""
	echo "Content-Disposition: attachment; filename=\"mytest.log\""
	echo "Content-Transfer-Encoding: base64"
	echo ""
	echo "$myfile"
	echo ""
	echo "--sep--"
	echo ""
        echo . 
        sleep 5 
        echo quit
   ) | telnet ${serverlist[$rand]} 25
else
    echo "$_file is empty."
        # do something as file is empty
fi

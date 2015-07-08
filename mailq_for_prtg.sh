#!/bin/bash
COUNT=`mailq | tail -1| awk '{print $5}'`

if [[ $COUNT =~ [0-9]+$ ]] ; then
	echo "1:$COUNT:There are $COUNT messages in mailq postfix"
else
	echo "0:0:There are 0 messages in mailq postfix"
fi

#!/bin/bash
#v1.5

from_addr="from email"
recipients="emails" #mail recipents seperated by ;
pagerduty_token="pagerduty"
workstart=05
workend=17

interval=10800 # check interval in seconds 10800 = 3 hours
workdir=`dirname $0`
emr="$workdir/emr/elastic-mapreduce"

instances () {
cat OUTPUT | grep "$1" > "$1"
while read line; do
	id=`echo $line | awk '{print $1}'`
	if [ "$id" != "$1" ]; then
		startdate=`$emr --describe --jobflow $id | grep CreationDateTime | head -n1 | cut -d ":" -f2 | tr -d ' ' | cut -d "." -f1`
		jobname=`$emr -j $id --list | head -n1 | awk '{print $4,$5,$6,$7}'`
		check_date "$startdate" "$id" "$1" "$jobname"
	fi
done < "$1"
rm "$1"
}

check_date () {
htime=`date -u -d @$interval +%H:%M:%S`
startdate=$1
now=`date +%s`
summerize=$(($now-$startdate)) ; summery=`date -d @$summerize +%H:%M:%S`

if [ "$summerize" -gt "$interval" ]; then
        echo "Problem - instance: $4, id: $2 is in $3 status and is up for $summery which is more than $htime "
	grep -q "$2" BadJobs > /dev/null 2>&1 ; [ "$?" != "0" ] && echo "$2" >> BadJobs
	alert "$4" "$2" "$3" "$summery" "$htime"
else
	echo "OK - instance: $4, id: $2 is in $3 status and is up for $summery which is less than $htime "
fi
}

alert () {
sendemail -f "from address" -t "$recipients" -m "Instance $1, $2 is in $3 status and is up for $summery which is more than $htime" -u "Warning - EMR Instance: $2 is up for $4"
Instance=`echo $1`
ID=`echo $2`
Status=`echo $3`
Duration=`echo $4`
Interval=`echo $5`

curl -XPOST "https://events.pagerduty.com/generic/2010-04-15/create_event.json" -H "Content-type: application/json" -d '{
          "service_key": "$pagerduty_token",
          "incident_key": "'$ID'",
          "event_type": "trigger",
          "description": "EMR Instance: '$Instance', is up for more than '$Interval'",
          "client": "AWS EMR",
          "client_url": "https://console.aws.amazon.com/elasticmapreduce/",
          "details": {
            "Instance": "'$Instance'",
            "ID": "'$ID'",
            "Status": "'$Status'",
            "Duration": "'$Duration'"
          } }'
}

resolve () {
if [ -f BadJobs ] && [ ! -s BadJobs ]; then rm BadJobs ; fi
if [ -f BadJobs ] && [ -s BadJobs ]; then
for line in `cat BadJobs`; do
	$emr -j $line --list | grep -q "TERMINAT*"
	if [ "$?" = "0" ]; then
	curl -XPOST "https://events.pagerduty.com/generic/2010-04-15/create_event.json" -H "Content-type: application/json" -d '{
          "service_key": "$pagerduty_token",
          "incident_key": "'$line'",
          "event_type": "resolve",
          "description": "EMR Instance: '$line', is terminated.",
          "client": "AWS EMR",
          "client_url": "https://console.aws.amazon.com/elasticmapreduce/",
          "details": {
            "Instance": "'$line'",
            "Status": "'Terminated'"
          } }'
		echo "Resolved - $line"
		sed -i "/$line/d" BadJobs
		sendemail -f "$from_addr" -t "$recipients" -m "Resolved - EMR Instance: $line is terminated" -u "Resolved - EMR Instance: $line is terminated."
	else
		echo "Instance $line is not terminated..."
	fi
done
else
	echo No Bad Jobs to resolve.
fi
}

monitor () {
[ -f OUTPUT ] && rm OUTPUT ; $emr --list > OUTPUT
instances RUNNING ; instances STARTING ; instances WAITING
[ -f OUTPUT ] && rm OUTPUT
}

solve () {
resolve
if [ -f BadJobs ] && [ ! -s BadJobs ]; then rm BadJobs ; fi
}
now=`date '+%H'`
if [ "$now" -lt "$workend" ] && [ "$now" -gt "$workstart" ]; then
        echo "The hour is $now and is between working hours: $workstart - $workend"
else
	if [ "$1" = "monitor" ]; then
		monitor
	elif [ "$1" = "resolve" ]; then
		solve
	else
		echo "syntax: $0 monitor/resolve"
	fi
fi

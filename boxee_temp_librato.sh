#!/bin/bash

BOXEE=yourboxeeip

if ping -oc 1 $BOXEE > /dev/null; then
  TOEKN=yourlibratotoken
	USER=yourlibratoemail
	TIME=`date +%s`
	TEMP=`curl -s -XGET http://$BOXEE:8080 | grep CPU | grep -o '[0-9]\+'`
	curl -w "%{http_code}" -u $USER:$TOEKN -d "measure_time=$TIME" -d 'source=boxee'   -d 'counters[0][name]=cpu_temp' -d "counters[0][value]=$TEMP" -XPOST https://metrics-api.librato.com/v1/metrics
exit
fi

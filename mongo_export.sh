#!/bin/bash
HOST=hostip
PORT=mongoport
USER=username
PASS=password
DDAY=`date +%s -d yesterday`
FILEDATE=`date +"%m-%d-%Y" -d yesterday`
DBNAME=mongodbname
COLNAME=collecitonname
CSVFILE=/mnt/csvfields.txt

#to csv
mongoexport -v -h "$HOST" --port "$PORT" --username $USER --password $PASS --authenticationDatabase admin --db $DBNAME --collection $COLNAME -q "{ updatedDate: { \$gte: new Date("$DDAY") }}" --csv --fieldFile $CSVFILE --out /mnt/mongo-data/$COLNAME-$FILEDATE.csv


#to json
mongoexport -v -h "$HOST" --port "$PORT" --username $USER --password $PASS --authenticationDatabase admin --db $DBNAME --collection $COLNAME -q "{ updatedDate: { \$gte: new Date("$DDAY") }}" --out /mnt/mongo-data/$COLNAME-$FILEDATE.json

exit

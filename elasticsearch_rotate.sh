#!/bin/bash
## using https://github.com/elasticsearch/curator

curator delete --prefix .marvel- --older-than 5
curator delete --prefix logstash- --older-than 14

exit

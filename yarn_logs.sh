#!/bin/bash
path=$(dirname "$0")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
export start_time=$(date  -d "12 hours ago" +%s%3N)
export current_time=$(date +%s%3N)
curl "http://hddev1db002dxc1.dev.oclc.org:8088/ws/v1/cluster/apps?state=failed&start-time=$start_time&end-time=$current_time" | python -m json.tool >jobs.txt
cat jobs.txt | jq  '.apps.app[] | { id, name, applicationType, finalStatus, startedTime, finishedTime, diagnostics, trackingUrl, amContainerLogs }'
length=$(cat jobs.txt | jq  '.apps.app[] .id' | wc -l)
for (( i=0; i<$length; i++ ));
do
echo $i;
Url=$(cat jobs.txt | jq -r ".apps.app[$i] .trackingUrl")
am_logurl=$(cat jobs.txt | jq -r ".apps.app[$i] .amContainerLogs")
app_id=$(cat jobs.txt | jq -r ".apps.app[$i] .id")
echo $Url
echo $app_id
curl -L "$Url"| grep -A3 -e ERROR -e exception -e reason -e exitCode | sort > /tmp/apps_work/$app_id
curl -L "$am_logurl"| grep -A3 -e ERROR -e exception -e reason -e exitCode | sort >> /tmp/apps_work/$app_id
done

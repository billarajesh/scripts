#!/bin/bash
path=$(dirname "$0")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
application_dir=/tmp/apps_work
application_dir_old=/tmp/apps_work_old
mkdir -p $application_dir $application_dir_old
chmod -R 777  $application_dir $application_dir_old
mv  $application_dir/* $application_dir_old/
export start_time=$(date  -d "72 hours ago" +%s%3N)
export current_time=$(date +%s%3N)
export yarn_url=xxxx

curl "http://$yarn_url:8088/ws/v1/cluster/apps?state=failed&start-time=$start_time&end-time=$current_time" | python -m json.tool > $path/jobs.txt
cat $path/jobs.txt | $path/jq  '.apps.app[] | { id, name, applicationType, finalStatus, startedTime, finishedTime, diagnostics, trackingUrl, amContainerLogs }' > $path/failed_list.json
length=$(cat $path/jobs.txt | $path/jq  '.apps.app[] .id' | wc -l)
for (( i=0; i<$length; i++ ));
do
echo $i;
Url=$(cat $path/jobs.txt | $path/jq -r ".apps.app[$i] .trackingUrl")
am_logurl=$(cat $path/jobs.txt | $path/jq -r ".apps.app[$i] .amContainerLogs")
app_id=$(cat $path/jobs.txt | $path/jq -r ".apps.app[$i] .id")
Owner=$(cat $path/jobs.txt | $path/jq -r ".apps.app[$i] .user")
echo $Url
echo $app_id
#curl -L "$Url"| grep -A3 -e IO exception -e scanner -e reason -e exitCode | sort > /tmp/apps_work/$app_id
#curl -L "$am_logurl"| grep -A3 -e ERROR -e exception -e reason -e exitCode | sort >> /tmp/apps_work/$app_id
yarn logs -applicationId $app_id -appOwner $Owner | grep -e 'Failed after retry of OutOfOrderScannerNextException' -e 'java.io.IOException: Could not seek StoreFileScanner' -e 'DoNotRetryIOException' -e 'OutOfOrderScannerNextException' -e 'java.net.SocketTimeoutException' -e ' running beyond physical memory limits' | sort | uniq |  head -n5
done
#echo "Please find the attached failed application list for last 1 hours ago \n Application dump directory $application_dir $hostname" | mail -s 'Failed application list' -a $path/failed_list.json  pathuris@oclc.org

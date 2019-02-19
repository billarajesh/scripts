#!/bin/bash

path=$(dirname "$0")
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
cat /dev/null > /tmp/failed_jobs.txt

resource_manager_url
{
for i in $(cat /etc/hadoop/conf/yarn-site.xml | grep '8088' | sed -e 's/<\/\?[^>]\+>//g' -e 's/ //g' )
do
echo $i
curl -L -i "http://$i/ws/v1/cluster/info" > /dev/null
status=$?
if [ $status -ne 0 ]
then
  echo "The command may have failed."
  else
  export yarn_url=$i
  echo $yarn_url
  return 0
fi
done
}

check_errors()
{
json_data=$(curl -L "http://$yarn_url/ws/v1/cluster/apps?state=failed&start-time=$start_time&end-time=$end_time" | python -m json.tool)
#cat $path/jobs.txt | $path/jq  '.apps.app[] | { id, name, applicationType, finalStatus, startedTime, finishedTime, diagnostics, trackingUrl, amContainerLogs }' > $path/failed_list.json
length=$(echo $json_data | $path/jq  '.apps.app[] .id' | wc -l)
for (( i=0; i<$length; i++ ));
do
echo $i;
Url=$(echo $json_data | $path/jq -r ".apps.app[$i] .trackingUrl")
am_logurl=$(echo $json_data | $path/jq -r ".apps.app[$i] .amContainerLogs")
app_id=$(echo $json_data | $path/jq -r ".apps.app[$i] .id")
Owner=$(echo $json_data | $path/jq -r ".apps.app[$i] .user")
echo $Url
echo $app_id
echo $Owner
#curl -L "$Url"| grep -A3 -e IO exception -e scanner -e reason -e exitCode | sort > /tmp/apps_work/$app_id
#curl -L "$am_logurl"| grep -A3 -e ERROR -e exception -e reason -e exitCode | sort >> /tmp/apps_work/$app_id
yarn logs -applicationId $app_id -appOwner $Owner | grep -e 'Failed after retry of OutOfOrderScannerNextException' -e 'java.io.IOException: Could not seek StoreFileScanner' -e 'DoNotRetryIOException' -e 'OutOfOrderScannerNextException' -e 'java.net.SocketTimeoutException' -e ' running beyond physical memory limits' | sort | uniq |  head -n5 >> /tmp/failed_jobs.txt
done
}

alert()
{
if [ -s /tmp/failed_jobs.txt ]
then
     echo -e "Please find the attached failed application list & errors encounted in it" | mail -s 'Failed application list' -a /tmp/failed_jobs.txt email@gmail.com
else
     echo "File empty"
fi
}

if [ "$#" -eq 2 ]
then
    if [ $1 == "minutes" ]
    then
    export start_time=$(date -u -d "$2 mins ago" +%s%3N)
    export end_time=$(date -u +%s%3N)
    resource_manager_url
    check_errors
    alert
    elif [ $1 == "hours" ]
    then
    export start_time=$(date -u  -d "$2 hours ago" +%s%3N)
    export end_time=$(date -u +%s%3N)
    resource_manager_url
    check_errors
    alert
    else
    echo "Argument can be either minutes or hours"
    fi
else
    echo "Missing Arguments"
    echo "Script Usage: $0 [minutes/hours] [value]"
fi

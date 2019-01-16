#!/bin/bash
if [ $# -eq 1 ]; then
Cluster_Name=$1
path=$(dirname "$0")
CM_HOST=<>
CM_USER=admin
CM_PWD=<>
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
curl -k  -u "$CM_USER:$CM_PWD" "https://$CM_HOST:7183/api/v18/clusters/$Cluster_Name/services" > $path/services.out
total_services=$(cat $path/services.out | .$path/jq '.items[].name'| wc -l)
count=$(echo $total_services-1 | bc)
for i in $(eval echo {0..$count})
do
#echo $i
status=$(cat $path/services.out | .$path/jq '.items['$i'].healthSummary' -r)
service=$(cat $path/services.out | .$path/jq '.items['$i'].name' -r)

if [ $status == "BAD" ]
then
echo $TIMESTAMP : $service status is $status
echo Service $service Health Checks status as below:
healthChecks_count=$(cat $path/services.out | .$path/jq '.items['$i'].healthChecks[].name' | wc -l)
health_count=$(echo $healthChecks_count-1 | bc)

for j in $(eval echo {0..$health_count})
do
healthCheck_Name=$(cat $path/services.out | .$path/jq '.items['$i'].healthChecks['$j'].name' -r)
healthCheck_Summary=$(cat $path/services.out | .$path/jq '.items['$i'].healthChecks['$j'].summary' -r)
echo $healthCheck_Name status is $healthCheck_Summary
done

else
echo $TIMESTAMP : $service status is $status
fi

done
else
    echo "Missing Arguments"
    echo "Script Usage: $0 <CM_Cluster_Name>"
fi

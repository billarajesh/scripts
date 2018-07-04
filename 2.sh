#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out

yarn_smoke_test()
{
hadoop jar /opt/cloudera/parcels/CDH/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar pi 10 100 > /tmp/pijobstats.txt
val2=$(cat /tmp/pijobstats.txt  | tail -n 1 | awk {'print $6'} | sed 's/\(\.[0-9][0-9]\)[0-9]*/\1/g')
if [ $val2 == 3.14 ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): YARN SMOKE CHECK: PASS" >> $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): YARN SMOKE CHECK: FAIL" >> $report
echo "Please check YARN Service as it is facing job failures" >> $report
fi
}
yarn_smoke_test

#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out

#HBASE SMOKE TEST
hbase_smoke_test()
{
rm /tmp/hbasestats.out
cat $path/hbasetablecreation.txt | hbase shell
echo "get 'smoketest:test', 'r1',{COLUMN => ['result']}" | hbase shell > /tmp/hbasestats.out 2>&1
counthbase=$(cat /tmp/hbasestats.out | grep -c hbasetest)
if [ $counthbase == 1 ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): HBASE SMOKE CHECK: PASS" >> $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): HBASE SMOKE CHECK: FAIL" >> $report
echo "Please check Hbase shell as it is facing job failures" >> $report
fi
}
hbase_smoke_test

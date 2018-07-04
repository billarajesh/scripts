#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out
#HIVE SMOKE TEST
hive_smoke_test()
{
hdfs dfs -rmr /benchmarks/smoketests/hivesmoketest/*
hdfs dfs -mkdir -p /benchmarks/smoketests/hivesmoketest/
file=/opt/cloudera/parcels/CDH/share/doc/solr-doc-4.10.3+cdh5.10.1+480/example/exampledocs/books.csv
hdfs dfs -put $file /benchmarks/smoketests/hivesmoketest/
$bline -f $path/hivequery.hql
$bline --showheader=false --outputformat=csv2 -e "select count(id) from smoketests.books_int;" > /tmp/hive_int.out
count=$(cat /tmp/hive_int.out)
if [ $count == 11 ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): HIVE SMOKE CHECK: PASS" >>  $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): HIVE SMOKE CHECK: FAIL" >>  $report
echo "Please check Hive beeline Service as it is facing job failures" >> $report
fi
}
hive_smoke_test

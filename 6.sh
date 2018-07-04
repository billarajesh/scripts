#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out

spark2_smoke_test()
{
hdfs dfs -rmr /benchmarks/smoketests/sparksmoketest/*
hdfs dfs -mkdir -p /benchmarks/smoketests/sparksmoketest
hdfs dfs -chmod -R 777 /benchmarks/smoketests/sparksmoketest
file=/opt/cloudera/parcels/CDH/lib/hue/apps/beeswax/data/web_logs_4.csv
file1=/etc/hbase/conf.cloudera.hbase/log4j.properties
hdfs dfs -put $file /benchmarks/smoketests/sparksmoketest

cat $path/spark_wordcount.txt | spark2-shell --master yarn
count_val=$(hadoop fs -cat /benchmarks/smoketests/sparksmoketest/output/wordcount/part-00000 | wc -l)
if [ $count_val -gt 0 ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): SPARK2 SMOKE CHECK: PASS" >> $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): SPARK2 SMOKE CHECK: FAIL" >> $report
echo "Please check spark2 shell/service as it is facing job failures" >> $report
fi
}
spark2_smoke_test

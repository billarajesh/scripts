#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out
hdfs_smoke_test()
{
#kinit -kt $(ls -tr /var/run/cloudera-scm-agent/process/*NODE/hdfs.keytab|tail -1) hdfs/$(hostname -f)
hdfs dfs -rmr /benchmarks/smoketests/hdfssmoketest/*
hdfs dfs -mkdir -p /benchmarks/smoketests/hdfssmoketest/
hdfs dfs -chmod -R 777 /benchmarks/smoketests/hdfssmoketest
echo "HDFSTEST" > /tmp/hdfstest.out
chmod 777 /tmp/hdfstest.out
hdfs dfs -put /tmp/hdfstest.out /benchmarks/smoketests/hdfssmoketest/
val1=$(hdfs dfs -cat /benchmarks/smoketests/hdfssmoketest/hdfstest.out)
val2=$(hdfs fsck /benchmarks/smoketests/hdfssmoketest/ -files -locations | grep Status | awk {'print $2'})
if [ $val1 == "HDFSTEST" ] && [ $val2 == "HEALTHY" ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): HDFS SMOKE CHECK: PASS" >> $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): HDFS SMOKE CHECK: FAIL" >> $report
echo "Please check HDFS Service as it is cannot read and write" >> $report
fi
}
hdfs_smoke_test

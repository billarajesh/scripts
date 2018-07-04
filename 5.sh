#!/bin/bash
path=$(dirname "$0")
source $path/config/config.properties
mkdir -p $path/report
mkdir -p $path/logs
report=$path/report/smoke_test_report.out

spark_smoke_test()
{
spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode cluster --master yarn /opt/cloudera/parcels/CDH/lib/spark/examples/lib/spark-examples*.jar 10 > /tmp/spark_job 2>&1
chmod 777 /tmp/spark_job
status=$(tail /tmp/spark_job | grep -c SUCCEEDED)
if [ $status -eq 1 ]
then
echo "$(date +"%Y-%m-%d %H:%M:%S"): SPARK SMOKE CHECK: PASS" >> $report
else
echo "$(date +"%Y-%m-%d %H:%M:%S"): SPARK SMOKE CHECK: FAIL" >> $report
echo "Please check spark-submit/service as it is facing job failures" >> $report
fi
}
spark_smoke_test

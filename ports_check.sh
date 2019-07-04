#!/bin/bash
user=admin
pwd=admin
cmhost=xxx
cmport=7183
clustername=xxx
tmpfile=/tmp/services.out
hostidfile=/tmp/hostids
hostnamefile=/tmp/hostnames
> $hostnamefile
> $hostidfile

services()
{
curl -u "$user:$pwd" "https://$cmhost:$cmport/api/v19/clusters/$clustername/services" > $tmpfile
}

port_check()
{
for service_names in $(grep $servicename_grep $tmpfile| grep name|awk {'print $NF'}| sed -e 's/"//g' -e 's/,//g')
do

curl  -u "$user:$pwd" "https://$cmhost:$cmport/api/v19/clusters/$clustername/services/$service_names/roles"|  grep -A10 $role |grep -i hostId | awk {'print $NF'}| sed 's/"//g' >> $hostidfile

done

for hostids in $(cat $hostidfile)
do

curl  -u "$user:$pwd" "https://$cmhost:$cmport/api/v19/hosts/$hostids"| grep -i hostname|  awk {'print $NF'}| sed -e 's/"//g' -e 's/,//g' >> $hostnamefile

done

for i in $(cat $hostnamefile)
do
nc -vz -w 5 $i $port
if [ $? == 0 ]
then
echo "$servicename_grep port $port connection for host $i - Passed"
else
echo "$servicename_grep port $port connection for host $i - Failed"
fi
done
}



zookeeper_port_check()
{
> $hostnamefile
> $hostidfile
servicename_grep=zookeeper
role=zookeeper-SERVER
port=2181
port_check
}

solr_port_check()
{
> $hostnamefile
> $hostidfile
servicename_grep=solr
role=solr-SOLR_SERVER
port=8985
tlsport=8985
port_check
}



services
zookeeper_port_check
solr_port_check

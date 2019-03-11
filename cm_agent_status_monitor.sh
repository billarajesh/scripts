#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Your command line contains no arguments"
else
    echo "$1"


collect()
{
TimeStamp=`date +"%Y-%m-%d %H:%M:%S"`
path=$(dirname "$0")
mkdir -p $path/log
file1=hosts.json
file2=hostsummary.json
fileurl=url.txt
curl -k  -u 'admin:D@t@Fabric1' 'https://usmkpapedf01.mck.experian.com:7183/api/v15/clusters/DataFabric1/hosts' > $path/$file1
}
collect

for i in $(cat $path/$file1|./jq '.items[].hostId' -r -S)
do
curl -k  -u 'admin:D@t@Fabric1' https://usmkpapedf01.mck.experian.com:7183/api/v15/hosts/$i > $path/$file2

if [ $(cat $directory/$file2 | ./jq '.hostname' -r) == '$1' ]
then
curl -k  -u 'admin:D@t@Fabric1' https://usmkpapedf01.mck.experian.com:7183/api/v15/hosts/$i > host_$(hostname)_agent_status.out
lastheartbeat=$(cat $path/log/host_$(hostname)_agent_status.out |./jq '.lastHeartbeat' -r
LastHeartBeatTime=starttime=$(date -d '$lastheartbeat' +%s%3N)
CurrentTime=$(date +%s%3N)
value=$(echo $CurrentTime - $LastHeartBeatTime | bc)

if [ $value >= 900000 ]
then
echo "CM Agent on Host - $hostname Status is BAD"
echo "Restarting the CM Agent Now"
else
echo "CM Agent on Host - $hostname Status is GOOD"
fi

else
echo "hostname not matched"
fi

done
fi

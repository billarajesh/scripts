#!/bin/sh 
df -H |grep -vE 'Filesystem|tmpfs' |awk '{print $1 "  used  "$5}'| while read percent; 
do
used=$(echo $percent|awk '{print $3}'| sed 's/.$//')
filesystem=$(echo $percent|awk '{print $1}')
dirdetails=$( cd / && sudo du -sch *| sort -rh)

if [ $used -ge 20 ]; then
echo "space on $filesystem is $used%  \n \n \nRoot Directory Details \n \n $dirdetails"| mail -s "Running out of space on $filesystem is $used%" rajesh.billa@infochimps.com
fi
done

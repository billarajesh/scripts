#!/bin/sh 
hadoop dfsadmin -report|grep "Datanodes"|awk '{print $3 " " $6}'|while read nodes;
do
deadnodes=$(echo $nodes|awk '{print $2}')
livenodes=$(echo $nodes|awk '{print $1}')
hn=$(hostname)
echo $deadnodes
if [ $deadnodes -gt 1 ]; then
echo "HostName : $hn \n No. of Dead Nodes : $deadnodes  \n No. of Live Nodes : $livenodes "| mail -s "Dead Nodes $deadnodes on $hn" rajesh.billa@infochimps.com
fi
done 

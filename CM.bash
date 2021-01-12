#!/bin/bash

#WRITTEN BY SUNNY KETH PATHURI
# THIS SCRIPT IS TO PULL THE DIFFERENCE BETWEEN THE CLUSTER CONFIGS OF SERVICES.

cm_config_get()
{
	cm_servicename=$(curl $ssl -i -u "$cm_user:$cm_pwd" "$url://$cm_host:$port/api/v19/clusters/$cluster/services" 2>/dev/null | grep $servicename | grep name | sed -e 's/[[:space:]]//g' -e 's/\"//g' -e 's/\,//g' | cut -d : -f2 | grep ^"$servicename" |head -n1)
	#COLLECT SERVICE ROLECONFIGGROUPS  FROM CM API
    curl $ssl -u "$cm_user:$cm_pwd" "$url://$cm_host:$port/api/v19/clusters/$cluster/services/$cm_servicename/roleConfigGroups" 2>/dev/null > $file1
    #COLLECT SERVICE CONFIGS OF ALL ROLES
	> /tmp/"$cluster".json
    for j in $(cat $file1|./jq '.items[].name' -r -S |grep BASE |grep -i "$rolename")
	do
		curl $ssl -u "$cm_user:$cm_pwd" "$url://$cm_host:$port/api/v19/clusters/$cluster/services/$cm_servicename/roleConfigGroups/$j/config" 2>/dev/null | /usr/local/bin/scripts/JSON.sh | grep -v 'items\"]'|grep -v '\[\]' | grep -v sensitive | sed 'N;s/\n/ /' | sed 's/\"items.*name"//' | sed 's/\"items.*value"//' | tr -d "[]" >> /tmp/"$cluster".json
	done
	chmod 777 /tmp/"$cluster".json
}


#CONDITION TO CHECK CM UI IS OPERATIONAL
cm_operational_check()
{
	status=$(curl $ssl -i -u "$cm_user:$cm_pwd" "$url://$cm_host:$port/api/v19/clusters" 2>/dev/null | grep -c  "200 OK")
	if [ $status == 1 ]
	then
		cm_config_get
	else
		echo "CM URL NOT REACHABLE - PLEASE CHECK - $url://$cm_host:$port"
		exit 1
	fi
}

# CM Variables Method
cluster_var_get()
{
	case $1 in
		Sandbox|Littlebox|Litterbox|littlebox)
			cm_host=cdhcmap01dxm1.dev.oclc.org
			cluster=littlebox
			ssl="-k"
			port=7183
			url="https"
        ;;
		THG1|thg1|Thg1)
			cm_host=hdthg1dm001dxm1.dev.oclc.org
			cluster=THG1
        ;;
		THG2|thg2|Thg2)
			cm_host=hdthg2dm001dxm2.dev.oclc.org
			cluster=THG2
        ;;
		DEV1|Dev1|dev1)
			cm_host=hddev1dm001dxm1.dev.oclc.org
			cluster=DEV1
        ;;
		NIT1|Nit1|nit1)
			cm_host=hdnit1dm001mxm1.nit.oclc.org
			cluster=NIT1
        ;;
		Grit|GRIT|grit|ORC1|Orc1|orc1)
			cm_host=hdorc1dm001dxm1.dev.oclc.org
			cluster=Grit
        ;;
		NAT1|Nat1|nat1)
			cm_host=hdnat1dm001nxm1.nat.oclc.org
			cluster=NAT1
        ;;
		NAT2|Nat2|nat2)
			cm_host=hdnat2dm001nxm1.nat.oclc.org
			cluster=NAT2
        ;;
		Prod1|PROD1|prod1)
			cm_host=hdprd1dm001pxm1.prod.oclc.org
			cluster=PROD1
        ;;
		Prod2|PROD2|prod2)
			cm_host=hdprd2dm001pxm1.prod.oclc.org
			cluster=PROD2
        ;;
		*)
			echo "Invalid cluster provided!"
			echo "Current Clusters are:  Sandbox, THG1, THG2, DEV1, NIT1, NAT1, NAT2, PROD1, PROD2, Grit"
			exit 1
	esac
}

cm_config_diff_check()
{
	cluster_var_get $1
	export cluster1=$cluster
	cluster_var_get $2
	export cluster2=$cluster
	echo "Difference for Files: File1-/tmp/"$cluster1".json  File2-/tmp/"$cluster2".json"
	echo "========================================================"
	echo -e "\e[1;35m  File1-/tmp/THG1.json  refers to color MAGENTA \e[0m"
	echo -e "\e[1;32m  File2-/tmp/THG2.json  refers to color GREEN \e[0m"
	echo  -e "\nThe difference of configs  between the two cluster is saved as \e[1;31m /tmp/"$cluster1"_"$cluster2"_"$DATE"_"$servicename"_"$rolename".out \e[0m"
	/usr/bin/colordiff -s /tmp/"$cluster1".json /tmp/"$cluster2".json | tee -a  /tmp/"$cluster1"_"$cluster2"_"$DATE"_"$servicename"_"$rolename".out
}

main_call()
{
	for cluster in $cluster1 $cluster2
	do
		cluster_var_get $cluster
		cm_operational_check
	done
}

if [ "$#" -eq 4 ]
then
	cluster1=$1
	cluster2=$2
	servicename=$3
	rolename=$4
#default variables for CM
    cm_user=tester
	cm_pwd=tester
	ssl=""
	port="7180"
	url="http"

	DATE=`date +"%Y-%m-%d"`
	path=$(dirname "$0")
	file1=/tmp/roleconfigGroups.json
	chmod 777 $file1
	> $file1
	
	main_call
	cm_config_diff_check $cluster1 $cluster2
	
else
	echo "Missing Arguments"
    echo "Script Usage: $0 <clustername1> <clustername2> <servicename> <rolename>"
fi
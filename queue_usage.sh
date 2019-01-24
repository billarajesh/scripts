format_time=$(date -d "12 hours ago" +%FT%T.%3NZ| sed 's/:/%3A/g')
curl -k  -u  xxx:xxx "https://sample.cloudera.com:7183/api/v18/timeseries?query=select+sum(allocated_memory_mb)%2C+sum(allocated_vcores)%2C+sum(apps_ingested_rate)+where+serviceName%3D%22yarn%22+and+category%3DYARN_POOL&from=$format_time&contentType=text%2Fcsv&desiredRollup=RAW&mustUseDesiredRollup=false" > data.txt
cat data.txt | grep allocated_memory | tr -d '" "'| cut -d ',' -f1,4 --output-delimiter=' '| awk {'print $1" "$2/(1024*1024)'} > mb
cat data.txt | grep vcores | tr -d '" "'| cut -d ',' -f1,4 --output-delimiter=' '| awk {'print $1" "$2*1'} > vc
cat mb  | sort -k 2nr | head -n 5| sed -e "s/([^)]*)/()/g" -e 's/())//g'

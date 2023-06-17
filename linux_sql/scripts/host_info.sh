#!/bin/bash

#Setup arguments
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Exit if arguments not equal to 5
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Save virtual memory, hostname and CPU statistics
vmstat_mb=$(vmstat --unit M)
lscpu_out=$(lscpu)
hostname=$(hostname -f)

#Retrieve hardware variables
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out"  | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out"  | egrep "^Model:" | awk '{print $2}' | xargs)
cpu_mhz=$(echo "$lscpu_out" | egrep "^CPU MHz:" | awk '{print $3}' | xargs)
l2_cache=$(echo "$lscpu_out" | egrep "^L2 cache:" | awk '{print $3}' | sed 's/K//' | xargs)
total_mem=$(echo "$vmstat_mb" | awk '{print $4}' | tail -n1 | xargs)

#Current time in UTC format
timestamp=$(vmstat -t | awk '{print $18,$19}'| tail -n1 | xargs)

#Insert data into host_info table
insert_stmt="INSERT INTO host_info(
		hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz,
                l2_cache, total_mem, timestamp
	       )
	        VALUES
       	       (
		'$hostname', '$cpu_number', '$cpu_architecture', '$cpu_model', '$cpu_mhz',
		'${l2_cache%%K}', '$total_mem', '$timestamp'
	       )";

#Set up variable for psql password
export PGPASSWORD=$psql_password
#Insert into database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?


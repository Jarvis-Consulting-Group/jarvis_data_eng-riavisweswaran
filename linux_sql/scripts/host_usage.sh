#! /bin/sh

#Assign arguments to variables
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

#Exit if parameters not equal to 5
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Save memory statistics
vmstat_mb=$(vmstat --unit M)
free_k=$(free -k)

#Retrieve usage variables
hostname=$(hostname -f)
memory_free=$(echo "$free_k" | egrep "^Mem:" | awk '{print $4}' | xargs)
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}'| tail -n1 | xargs)
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}'| tail -n1 | xargs)
disk_io=$(vmstat -d | awk '{print $10}' | tail -n1 | xargs)
disk_available=$(df -BM / | awk '{print $4}' | tail -n1 | tr -d 'M' | xargs)

#Current time in UTC format
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

#Find matching id in host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

#Insert server usage data into host_usage table
insert_stmt="INSERT INTO host_usage("timestamp", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES ('$timestamp', '$host_id', '$memory_free', '$cpu_idle', '$cpu_kernel', '$disk_io', '$disk_available');"

#Psql password
export PGPASSWORD=$psql_password
#Insert into database
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?


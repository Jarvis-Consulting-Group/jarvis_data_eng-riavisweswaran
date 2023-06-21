# Linux Cluster Monitoring Agent

## Introduction
The Linux Cluster Monitoring Agent is a tool designed to gather hardware information of servers and monitor minute-by-minute resource usage. The system runs a series of bash scripts to store the information in a PostgreSQL database within a Docker container for each node in the Linux cluster. The agent uses crontab to retrieve minute-by-minute host usage statistics and insert them into the database. Based on the stored information, users can write SQL queries to generate reports for future resource planning purposes.

The project utilizes Docker to provision the PSQL instance, bash scripts to retrieve the information, PostgreSQL to store the information, and Git to manage the code. The monitoring agent was tested on a remote desktop running CentOS 7.

## Quick Start
```bash
#Start a psql instance using psql_docker.sh
./scripts/psql_docker.sh start

#Create tables using ddl.sql
psql -h localhost -U postgres -d host_agent -f sql/ddl.sql

#Insert hardware specs data into the DB using host_info.sh
./scripts/host_info.sh localhost 5432 host_agent postgres password

#Insert hardware usage data into the DB using host_usage.sh
./scripts/host_usage.sh localhost 5432 host_agent postgres password

#Crontab setup
crontab -e
#Add in editor to collect usage statistics every minute
* * * * * bash /home/centos/dev/jrvs/bootcamp/linux_sql/host_agent/scripts/host_usage.sh localhost 5432 host_agent postgres password > /tmp/host_usage.log
```
## Implementation
To implement the project, we set-up a Linux environment running CentOS 7 and designed an MVP to enable the LCA team to write SQL queries for future resource planning.

Our implementation approach started with installing Docker, provisioning a psql instance, and installing the psql CLI tool. From there, we created a container to host a PostgreSQL database and designed a schema to store hardware statistics. The Linux cluster monitoring agent was developed using two bash scripts: `host_info.sh` to retrieve hardware specifications and `host_usage.sh` to provide minute-to-minute monitoring of server usage. `Host_info.sh` was executed once during installation and inserted into the PostgreSQL database. `Host_usage.sh` executes every minute through a cron job to provide server usage data. 

## Architecture

## Scripts
- _psql_docker.sh:_
  - The script creates a psql instance within a docker container. 
  - It contains three input variables: username, password and input command. 
  - The script checks the status of the Docker container and uses a switch case to create, start or stop the container based on the input command.
- _host_info.sh:_
  - The script collects hardware information of the Linux host and inserts into the PostgreSQL database.
  - The script is run once during installation.
- _host_usage.sh:_
  - The script collects server usage data and inserts it into the PostgreSQL database.
  - The script is scheduled to run every minute using crontab.
- _crontab:_
  - Crontab monitors the data on each server by running host_usage.sh every minute.
  - The server usage statistics are stored and updated minute-to-minute in the PostgreSQL database
- _queries.sql:_
  - Users can write SQL queries to retrieve the data stored in the PostgreSQL database

## Database Modeling
The host_info table is used to store hardware specifications of each Linux host.
The primary key for this table is id and the unique constraint is hostname.

### Schema of host_info:
| Column Name  | Data Type | Description                              |
|--------------|-----------|------------------------------------------|
| id           | SERIAL    | Unique identifier                        |
| hostname     | VARCHAR   | Name of host                             |
| cpu_number   | INTEGER   | Number of CPUs in host                   |
| cpu_architecture | VARCHAR | Host CPU Architecture                  |
| cpu_model    | VARCHAR   | Host CPU Model                           |
| cpu_mhz      | FLOAT      | Host CPU clock speed (mhz)              |
| l2_cache     | INTEGER   | Host L2 cache size (KB)                  |
| total_mem    | INTEGER   | Total memory in the host (KB)            |
| timestamp    | TIMESTAMP | Timestamp of when the data was collected |

The host_usage table is used to store hardware usage of each Linux host.
The foreign key constraint on this table is host_id which is referenced in the host_info table.

### Schema of host_usage:
| Column Name  | Data Type | Description                                      |
|--------------|-----------|--------------------------------------------------|
| timestamp    | TIMESTAMP | Timestamp of when usage statistics were inserted |
| host_id      | INTEGER   | Referencing ID from host_info table              |
| memory_free  | INTEGER   | Free memory in host (MB)                         |
| cpu_idle     | INTEGER      | CPU idle time                                    |
| cpu_kernel   | INTEGER      | CPU kernel code                                  |
| disk_io      | INTEGER   | Number of disk I/O operations                    |
| disk_available | INTEGER  | Available disk space (MB)                        |

## Test
- Test psql_docker.sh
  ```bash
  #Verify that the container is running.
  docker ps -f name=jrvs-psql
  ```
### Result:
  | CONTAINER ID | IMAGE | COMMAND | CREATED    | STATUS    |PORTS | NAMES |
  | --- | --- | --- |------------|-----------| --- | --- |
  | 3929a630fbb8 | postgres:9.6-alpine | "docker-entrypoint.s"| 6 days ago | Up 6 days | <br/>0.0.0.0:5432->5432/tcp, :::5432->5432/tcp | jrvs-psql |

- Test host_info.sh
 ```bash
#Check if hardware info has been inserted into the database
SELECT * FROM host_info;
  ```
### Result:
|id | hostname | cpu_number | cpu_architecture | cpu_model | cpu_mhz  | l2_cache | timestamp           | total_mem |
| --- | --- | --- | --- |----|----------|-----|---------------------|--------|
|1 | jrvs-remote-desktop-centos7-6.us-central1-a.c.spry-framework-236416.internal| 2 | x86_64 | 63 | 2299.998 | 256 | 2023-06-14 13:16:23 | 1378   |

- Test host_usage.sh
 ```bash
#Check if server usage data has been inserted into the database
SELECT * FROM host_usage;
  ```
### Result:
| timestamp           | host_id | memory_free | cpu_idle | cpu_kernel | disk_io | disk_available |
  |---------------------| --- |------|----|---|----|----------------|
| 2023-06-20 18:03:01 | 1 | 1378 | 90 | 4 | 2  | 3              |

- Test crontab
 ```bash
#Check timestamps to verify that server usage data has been inserted into the database every minute
SELECT * FROM host_usage;
  ```
### Result:
| timestamp           | host_id | memory_free | cpu_idle | cpu_kernel | disk_io | disk_available |
  |---------------------| --- |--------|----------|------------|---------|----------------|
| 2023-06-20 18:03:01 | 1 | 1378   | 90       | 4          | 2       | 3              |
| 2023-06-20 18:04:00 | 1 | 1376   | 90       | 4          | 2       | 3              |

## Deployment

### Docker
Install Docker.
Provision PostgreSQL instance using Docker.
### Git
Access `psql_docker.sh`, `ddl.sql`, `host_usage.sh`, and `host_usage.sh` from Github repository.
### PostgreSQL
Start PostgreSQL container using `psql_docker.sh`.
Execute `ddl.sql` script to create the host_info and host_usage tables in PostgreSQL.
Use `host_info.sh` to insert hardware specification into the database.
### Crontab
Use a cron job to execute `host_usage.sh` and insert usage data into the database every minute.

A combination of Docker, Git and Crontab were used to deploy and maintain the application.

## Improvements
- Analytics: implement a feature to report on capacity constraints and usage patterns to streamline resource planning for users.
- Visual interface: build graphical user interface to view key metrics at a glance.
- Detect issues: set up alerts for failed nodes as well as inefficient CPU utilization and memory allocation.







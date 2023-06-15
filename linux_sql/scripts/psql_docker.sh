#!/bin/bash
cmd=$1
db_username=$2
db_password=$3

#Start docker
sudo systemctl status docker || sudo systemctl start docker

#Check container status and store in container_status variable
docker container inspect jrvs-psql
container_status=$?

#Create cases to check for start|stop|create with corresponding messages
case $cmd in
  create)

  #Check if container exists
  if [ $container_status -eq 0 ]; then
     echo 'Container already exists'
     exit 1
  fi

  #Check number of CLI arguments
  if [ $# -ne 3 ]; then
     echo 'Create requires username and password'
     exit 1
  fi

  #Create container
  docker volume create psql_data

  #Start with username and password
  docker run --name jrvs-psql -e POSTGRES_USER=$db_username -e POSTGRES_PASSWORD=$db_password -d -v psql_data:/var/lib/postgresql/data -p 5432:5432 postgres:10
  exit $?
  ;;

  start|stop)
  #Check container status and exit if container has not been created
  if [ $container_status -eq 1 ]; then
     echo "Container does not exist. Please create the container."
     exit 1
  fi

  #Start or stop the container
  docker container $cmd jrvs-psql
  exit $?
  ;;

  #Unknown case
  *)
     echo 'Illegal command'
     echo 'Commands: start|stop|create'
     exit 1
     ;;
esac


#!/bin/bash

set -e

# Variables
export EMP_VERSION=snapshot
export EMPURL=https://emp-server/emp

export INT_VERSION=2.6.2.1
export INT_HOST=int-server
export INT_PORT=8080
export INTURL=https://$INT_HOST:$INT_PORT
export MTU_SIZE=1450

dockerComposeFile=docker-compose.yml

cmdname=$(basename $0)
echoerr() { echo "$@" 1>&2; }

usage() {
    cat << USAGE >&2

Controls Local Docker Integrated Denmark Environment

Usage:
    $cmdname [--aws] --up | --down | --pull | --start | --stop | --int | --emp
    $cmdname --run-sql <FILE>
    $cmdname -h | --help

Options:
    -h --help           Show this screen.
    --up                Create and start containers
    --down              Stop and remove containers, networks, images, and volumes
    --pull              Pull service images
    --start             Start services
    --stop              Stop services
    --int               Start only Integration services
    --emp               Start only EMP services
    --aws               Pull and use images from AWS docker registry
    --run-sql <FILE>    Execute the specified FILE present in sql directory

USAGE
    exit 1
}

function aws() {
  dockerComposeFile=docker-compose-aws.yml
}

function pull() {
    docker-compose -f $dockerComposeFile pull
}

function down() {
    docker-compose -f $dockerComposeFile down
    sudo rm -rf .nemlogin
}

function stop() {
    docker-compose -f $dockerComposeFile stop
}

function up() {
    down
    prepare
    docker-compose -f $dockerComposeFile up -d
    jbosswait
}

function int() {
  prepare
  docker-compose -f $dockerComposeFile up -d int-server nemloginmock cprmock intpostgres
}

function emp() {
  docker-compose -f $dockerComposeFile up -d empdb-dnk emp-server
  jbosswait
}

function start() {
    docker-compose -f $dockerComposeFile start
    jbosswait
}

function prepare() {
    cp -r nemlogin .nemlogin
    NEMIDURL=http://$INT_HOST:8081/idp
    CHIDURL=http://$INT_HOST:8081/idp
    ORIGIDP="http://52.213.209.35:8081/idp"
    ORIGINT="http://52.213.209.35"
    sed -i -e 's,'"$ORIGIDP"','"$CHIDURL"',g' .nemlogin/metadata/IdP/ContextHandlerMockMetadata.xml
    sed -i -e 's,'"$ORIGIDP"','"$NEMIDURL"',g' .nemlogin/metadata/IdP/NemLoginMockMetadata.xml
    sed -i -e 's,'"$ORIGINT"','"$INTURL"',g' .nemlogin/metadata/SP/SPMetadata.xml
}

function runSql() {
  local fileName=$1
  docker exec -e ORACLE_HOME=/home/oracle/app/oracle/product/12.1.0/dbhome_1 \
    -e ORACLE_SID=XE empdb-dnk \
    /home/oracle/app/oracle/product/12.1.0/dbhome_1/bin/sqlplus aes/aes@localhost:1521/XE @/u01/app/oracle/support/$fileName
}

function jbosswait() {
  jboss=0
  error=0
  start=`date +%s`
  echo -------------------- Iniciando Jboss por favor espere ... --------------
  while [ $jboss -lt 1 ] && [ $error -lt 1 ];
    do
      if [ $(docker logs emp-server | grep "started in" | wc -l) = "1" ]; then
        end=`date +%s`
        runtime=$((end-start))
        echo Jboss started in $runtime seconds
        jboss=$((jboss+1))
      elif [ $(docker logs emp-server | grep " stopped in " | wc -l) = "1" ]; then
        end=`date +%s`
        runtime=$((end-start))
        echo Error detected in $runtime seconds
        error=$((error+1))
        exit 1
      fi
    done
}

# process arguments
if [ $# -eq 0 ]; then
    usage
fi

while [[ $# -gt 0 ]]
do
  case "$1" in
    --aws)
    aws
    shift # past argument
    ;;
    --up)
    up
    shift # past argument
    ;;
    --start)
    start
    shift # past argument
    ;;
    --down)
    down
    shift # past argument
    ;;
    --stop)
    stop
    shift # past argument
    ;;
    --pull)
    pull
    shift # past argument
    ;;
    --prepare)
    prepare
    shift # past argument
    ;;
    --int)
    int
    shift # past argument
    ;;
    --emp)
    emp
    shift # past argument
    ;;
    --run-sql)
    runSql $2
    shift 2 # past argument
    ;;
    -h | --help)
    usage
    ;;
    *)
    echoerr "Unknown argument: $1"
    usage
    ;;
  esac
done

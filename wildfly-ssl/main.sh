#!/usr/bin/env bash

war_file_name=wildfly-helloworld-war-ssl.war
docker_image_name=wildfly-helloworld-war-ssl

mvn -f sample-app clean package
cp sample-app/target/$war_file_name wildfly-docker

cd wildfly-docker
docker build -t $docker_image_name .
rm $war_file_name
cd ..

docker run -it -p 8443:8443 -p 8080:8080 $docker_image_name

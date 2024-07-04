#!/bin/sh

docker pull --platform linux/amd64 nginx:latest
docker tag nginx:latest $1:0.0.0
docker push $1:0.0.0

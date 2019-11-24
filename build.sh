#!/bin/bash

docker build -t singam-nginx .

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "tagging the image with the exact name as the remote image as docker push requires"
docker tag singam-nginx arundeva/singam-nginx

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "pushing arundeva/singam-nginx"
docker push arundeva/singam-nginx

if [ $? -ne 0 ]; then
  echo "Did you login to remote repo using the 'docker login' command?"
fi

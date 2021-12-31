#!/bin/bash
VERSION=1.0.0
docker build -t singam-nginx:$VERSION .

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "tagging the image with the exact name as the remote image as docker push requires"
docker tag singam-nginx:$VERSION arundeva/singam-nginx:$VERSION

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "pushing arundeva/singam-nginx:$VERSION"
docker push arundeva/singam-nginx:$VERSION

if [ $? -ne 0 ]; then
  echo "Did you login to remote repo using the 'docker login' command?"
fi

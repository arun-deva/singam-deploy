#!/bin/bash
VERSION=1.0.2
IMAGE=singam-nginx
docker build -t $IMAGE:$VERSION .

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "tagging the image with the exact name as the remote image as docker push requires"
docker tag $IMAGE:$VERSION arundeva/$IMAGE:$VERSION

if [ $? -ne 0 ]; then
  echo "Exiting"
  exit 1
fi

echo "pushing arundeva/$IMAGE:$VERSION"
docker push arundeva/$IMAGE:$VERSION

if [ $? -ne 0 ]; then
  echo "Did you login to remote repo using the 'docker login' command?"
fi

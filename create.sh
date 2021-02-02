#!/bin/bash

REPO=ftps
VERSION=1.0.0

if [  ! -f Dockerfile ]; then
  echo "not a docker configuration"
  return 1
fi

docker stop $REPO
docker rm $REPO
docker rmi mhus/$REPO:$VERSION

if [ "$1" = "clean" ]; then
  docker rmi mhus/$REPO:$VERSION
  docker build --no-cache -t mhus/$REPO:$VERSION .
  shift
else
	docker build -t mhus/$REPO:$VERSION .
fi

if [ "$1" = "test" ]; then
  docker run -d --name $REPO \
    --env USERS="user1 user2 user3" \
    --env PASSWD_user1=abc \
    --env PASSWD_user2=xxx \
    --env PASSWD_user3=asd \
    --env PASSV_MAX_PORT=10100 \
    -p 20:20 \
    -p 21:21 \
    -p 10000-10100:10000-10100 \
    mhus/$REPO:$VERSION
  docker logs -f $REPO

fi

if [ "$1" = "push" ]; then
    docker push "mhus/$REPO:$VERSION"
    docker tag "mhus/$REPO:$VERSION" "mhus/$REPO:last"
    docker push "mhus/$REPO:last"
fi 

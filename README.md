## Build and push Docker image for singam-nginx (in dev env)
Assumes that latest ui tgz files are in the ui-dist directory

```./build.sh```

## Deploy (on destination instance)

Pull down the docker compose file from github
```
curl https://raw.githubusercontent.com/arun-deva/singam-deploy/master/docker-compose.yml > /home/ec2-user/singam-deploy/docker-compose.yml
```

```
docker-compose down
docker-compose pull
docker-compose up -d
```


# bedrock-in-docker
Docker image for install, update, backup&restore and run the Minecraft Bedrock server. Some of scripts are forked or inspired from great [MinecraftBedrockServer](https://github.com/TheRemote/MinecraftBedrockServer) project.

## Quick reference
* Project source repository: (https://github.com/tchorwat/bedrock-in-docker)
* In case of any bugs raise a ticket through GitHub (https://github.com/tchorwat/bedrock-in-docker/issues) issues page, please.
* Supported architectures: `amd64`

## Usage

### Starting deamon

To run Bedrock server instance simply run:
```
docker run -d -p 19132:19132/udp tchorwat/bedrock-in-docker
```

The command above will download (see  https://minecraft.net/terms for terms), install, run bedrock_server inside container and expose server on 19132 host port. As for common docker usage, you can run and expose several other instances as long a port per host/ip doesn't collide each others. By example you can:
```
docker run -d -p 19142:19132/udp --name my_instance_1 tchorwat/bedrock-in-docker
docker run -d -p 19152:19132/udp --name my_instance_2 tchorwat/bedrock-in-docker
docker run -d -p 192.168.1.100:19132:19132/udp --name my_instance_3 tchorwat/bedrock-in-docker
docker run -d -p 192.168.1.101:19132:19132/udp --name my_instance_4 tchorwat/bedrock-in-docker
```

To override some of default server configuration files, map your files as follow:
```
docker run -d -p 19132:19132/udp \
  -v <absolute_host_path_to_yours_one>:/bedrock/server.properties \
  -v <absolute_host_path_to_yours_one>:/bedrock/permissions.json \
  -v <absolute_host_path_to_yours_one>:/bedrock/whitelist.json \
  tchorwat/bedrock-in-docker
```

Consider add restart policy, to start container if it's stops for some reason:
```
docker run -d --restart unless-stopped -p 19132:19132/udp tchorwat/bedrock-in-docker
```

### Persist the data

You should consider bind two Docker volumes to persists your data in case of need to delete container or update docker image. Just add two additional volume mapping:
```
docker run -d -p 19132:19132/udp \
  -v your-volume-name-worlds:/bedrock/worlds \
  -v your-volume-name-backups:/backups \
  tchorwat/bedrock-in-docker
```

### Update Bedrock server

bedrock-in-docker will download and update to latest server release (from https://www.minecraft.net/en-us/download/server/bedrock) each time when it starts. You can configure bedrock-in-docker to restart bedrock and do the update periodically, by passing restart&update UTC time (default is 03:00 UTC):
```
docker run -d -p 19132:19132/udp \
  -e BEDROCK_IN_DOCKER_RESTART_TIME_UTC="02:00"
  tchorwat/bedrock-in-docker
```
or you can disable restarting by set some date in the far future:
```
docker run -d -p 19132:19132/udp \
  -e BEDROCK_IN_DOCKER_RESTART_TIME_UTC="12/31/2999"
  tchorwat/bedrock-in-docker
```

### Backups
Each time when stops (or restart) backup will be executed. You can see the backup files by mounting backup folder to host:
```
docker run -d -p 19132:19132/udp \
  -v <absolute_host_path_to_yours_backup_directory>:/backups \
  tchorwat/bedrock-in-docker
```

or (preferred) by attaching to the container bash:
```
docker exec -it my_instance_1 bash
ls -al /backups
```

To restore latest.tar.gz start the container with environment variable: `BEDROCK_IN_DOCKER_FORCE_RESTORE=1`, by example:
```
docker run -d -p 19132:19132/udp \
  -v your-volume-name-worlds:/bedrock/worlds \
  -v your-volume-name-backups:/backups \
  -e BEDROCK_IN_DOCKER_FORCE_RESTORE=1 \
  tchorwat/bedrock-in-docker
```

If you need to restore some other backup, just replace /backups/latest.tar.gz with something else.

### Updating the container
Before recreating container with new image MAKE SURE that your data is persisted to docker volumes (or mapped to host).
Stop the container, pull new image, run new one and delete old one if everything works:
```
docker stop bedrock_1_v1
docker pull tchorwat/bedrock-in-docker
docker run -d -p 19132:19132/udp \
  --name bedrock_1_v2
... \
  -v bedrock_1-worlds:/bedrock/worlds \
  -v bedrock_1-backups:/backups \
  tchorwat/bedrock-in-docker
docker rm bedrock_1_v1
```

## S3 Support
Tag tchorwat/bedrock-in-docker:__s3__ support storing backup of worlds and config files in s3 bucket. Two additional environment variables was added:
- BEDROCK_IN_DOCKER_BACKUP_s3_URI - uri to bucket and prefix to store backup data, by example: `s3://<your-bucket>/<your-prefix>`
- BEDROCK_IN_DOCKER_CONFIG_s3_URI - uri to bucket and prefix to store config files, by example: `s3://<your-bucket>/<your-prefix>/config`. Only:`server.properties`, `permissions.json`, `whitelist.json` will be stored.

To initialize new container just put your files inside `s3://<your-bucket>/<your-prefix>/config` and start container:

```
λ docker run -d --restart unless-stopped --name <your-container-name> \
  -p 19132:19132/udp -p 19133:19133/udp \
  -e BEDROCK_IN_DOCKER_BACKUP_s3_URI=s3://<your-bucket>/<your-container-name> \
  -e BEDROCK_IN_DOCKER_CONFIG_s3_URI=s3://<your-bucket>/<your-container-name>/config \
  -e AWS_ACCESS_KEY_ID=<your-key-id> \
  -e AWS_SECRET_ACCESS_KEY=<your-secret-key> \
  tchorwat/bedrock-in-docker:s3
```

Hint 1: if your run your container inside AWS infrastructure consider use IAM role instead passing credentials.
Hinr 2: Don't forget to set lifecycle rule for your bucket to manage backup retention.

## Releases

### v0.1.0 Initial (alpha) release
This is the initial (alpha) release of bedrock-in-docker.

Features:
- Support of s3 & local path backup was introduced.

## Real examples

### 1
Run named instance with mounted docker volumes, that will preserve host restart:
```
docker run -d --restart unless-stopped \
  --name bedrock_1 \
  -p 19132:19132/udp \
  -p 19133:19133/udp \
  -v $(pwd)/server.properties:/bedrock/server.properties \
  -v $(pwd)/permissions.json:/bedrock/permissions.json \
  -v $(pwd)/whitelist.json:/bedrock/whitelist.json \
  -e BEDROCK_IN_DOCKER_RESTART_TIME_UTC="03:00" \
  -v bedrock_1-worlds:/bedrock/worlds \
  -v bedrock_1-backups:/backups \
  tchorwat/bedrock-in-docker
```

## License
This Docker image is built on ubuntu Docker images https://hub.docker.com/_/ubuntu. View [license information for Ubuntu](https://ubuntu.com/licensing).

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

View [**bedrock-in-docker** project MIT license](https://github.com/tchorwat/bedrock-in-docker/blob/main/LICENSE)

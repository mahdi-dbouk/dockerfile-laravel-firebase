# dockerfile-laravel-firebase

Building the Image:
```
docker build -t <Tag-Name> . //in root directory
```

Running an image:

```
docker run -d -p {External PORT}:80 <tag-name>
//8000:80 
```

Stopping a running container:

```
//view all containers
docker ps -a

//stop container by ID
docker stop <container-id>
```


## Backgounding
-d to background, and -it to be interactive, even when reattaching
```
docker start -d -it --name tut -t ubuntu:20.04 /bin/bash 
```
to reattach:
```
docker attach tut
```
to exit any container without stopping it:
```
Ctrl+p, then Ctrl+q
```
stop and (optional) delete container:
```
docker stop tut && docker container prune
```


## Volumes

**Ex**

*Create a Volume*
```
docker volume create myvolume
```

*use the volume*
'''
docker run --mount source=volume-name,destination=path-inside-container docker-images
'''

**Default Values**
 - puts volume dir in /var/lib/docker/volumes/lolvol
 - (in container) mounts volume in /data
'''
docker volume create lolvol
docker run --name ubuntutut -it --mount source=lols,destination=/data -t ubuntu:20.04 /bin/bash
'''

**Custom Values**
 - put volume dir in specified dir on external drive
 - (in container) mount volume in /dbs/data
 - 

## SSH

## Network Files

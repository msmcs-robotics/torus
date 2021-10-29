
## Backgounding
-d to background, and -it to be interactive, even when reattaching
```
docker start -d -it --name ubuntudev -t ubuntu:20.04 /bin/bash 
```
to reattach:
```
docker attach ubuntudev
```
to exit any container without stopping it:
```
Ctrl+p, then Ctrl+q
```
stop and remove container:
```
docker stop ubuntudev && docker container prune
```


## Volumes

**Use a specified Folder as a mount point...**

*On an external, mounted drive, make a folder named dbs, 
and mount dbs in a new folder called datahere, in the opt dir, of in the container*
```
docker run --name ubuntudev -it -v /mounteddrive/dbs:/opt/dbs -t ubuntu:20.04 /bin/bash
```

## SSH
```
```


## Network Files

```
7z a ${archive_name}-$time.7z $DOCKER_VOLUME_DIR
smbclient \\\\$smbaddr\\$smbshare -U '${smbuser}' $smbpass --directory $dir_on_share -c "put ${archive_name}-$time.7z"
```

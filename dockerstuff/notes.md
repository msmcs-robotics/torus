
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

**Used for storing NN data & model archives**

*On an external, mounted drive, make a folder named dbs, 
and mount dbs in a new folder called datahere, in the opt dir, of in the container*
```
docker run --name ubuntudev -it -v /mounteddrive/dbs:/opt/dbs -t ubuntu:20.04 /bin/bash
```

## SSH
```
```


## Network Files

**Used for interacting with folders use for docker volume (available on SMB shares) over the network**

*copy data from NAS*
```
smbclient \\\\$smbaddr\\$smbshare -U '${smbuser}' $smbpass --directory $dir_on_share -c "get ${model_name}-$version.7z"
```

*copy data to NAS*
```
7z a ${model_name}-$new_version.7z $path_to_docker_volume
smbclient \\\\$smbaddr\\$smbshare -U '${smbuser}' $smbpass --directory $dir_on_share -c "put ${model_name}-$new_version.7z"
```

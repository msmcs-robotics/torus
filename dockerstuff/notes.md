
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

**Used for storing NN data & models**

*On an external, mounted drive, make a folder named dbs, 
and mount dbs in a new folder called datahere, in the opt dir, of in the container*
```
docker run --name ubuntudev -it -v /mounteddrive/dbs:/opt/dbs -t ubuntu:20.04 /bin/bash
```

## Network Files

**Used for interacting with folders containing docker volume (available on SMB shares) over the network**

*This should make data persistent, so if a container crashes, data would still exist on the mounted volume, and one could just prune and re-deploy a container*

*copy archive from NAS*
```
smbclient \\\\$smbaddr\\$smbshare -U '${smbuser}' $smbpass --directory $dir_on_share -c "get ${model_name}-$version.7z"
```

*make an archive with update model, and copy back to NAS*
```
7z a ${model_name}-$new_version.7z $path_to_docker_volume
smbclient \\\\$smbaddr\\$smbshare -U '${smbuser}' $smbpass --directory $dir_on_share -c "put ${model_name}-$new_version.7z"
```

## GUI App Support (Stats & Health Checks for reports)

**Example Image**
*on host*
```
docker pull consol/ubuntu-xfce-vnc
docker run -d -it --name ubuntu-xfce-tut -p 5901:5901 -p 6901:6901 consol/ubuntu-xfce-vnc bash
docker container inspect -f '{{ .NetworkSettings.IPAddress }}' ubuntu-xfce-tut
```
*in browser visit...*
```
http://containerip:6901/vnc_auto.html?password=vncpassword
```

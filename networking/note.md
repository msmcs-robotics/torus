

## Setup static ip for ethernet interface

**Debian**

```
sudo ip addr add [ip]/[mask] [bridgename] [interface]
sudo ip addr del [ip]/[mask] [bridgename] [interface]
```

Example: 
```
sudo ip addr add 192.168.10.1/24 dev eth0
sudo ip addr del 192.168.10.1/24 dev eth0
```

**Arch**

```
ip address del [ip]/[mask] [bridgename] [interface]
ip address del [ip]/[mask] [bridgename] [interface]
```

# bnmap
### Bash Network Mapper

Simple and quick network mapper tool coded in bash. It does host discovery through the **ICMP** protocol, finds open ports by using the bash shell `/dev/tcp/..` pseudo-device, and support the **255.255.0.0** subnet mask.

### Help Menu
> ./bnmap.sh -h
```
[!] Use: ./bnmap.sh
-------------------------------------------------------------------------------------
        [-i] Scan interface. Default subnet mask: 255.255.255.0 (Example: -i eth0)
        [-s] Scan interface, but with subnet mask: 255.255.0.0 (Example: -s eth0)
        [-p] Scan open ports of a host. [Firts 10000 ports] (Example: -p 192.168.1.1)
        [-h] Show this help menu.
```
### Basic Usage. Scan network on interface eth0
> ./bnmap.sh -i eth0
```
[*] Scanning network: 192.168.1.0/24

        [*] Host 192.168.1.1 ACTIVE
                [!] Port open: 192.168.1.1:53
                [!] Port open: 192.168.1.1:80
                [!] Port open: 192.168.1.1:139
                [!] Port open: 192.168.1.1:445
                [!] Port open: 192.168.1.1:443
```
### Scan network on interface eth0 with the 255.255.0.0 subnet mask.
> ./bnmap.sh -s eth0
```
[*] Scanning network: 192.168.0.0/16

  [*] Scanning network: 192.168.1.0/24
        [*] Host 192.168.1.1 ACTIVE
                [!] Port open: 192.168.1.1:53
                [!] Port open: 192.168.1.1:80
                [!] Port open: 192.168.1.1:139
                [!] Port open: 192.168.1.1:443
                [!] Port open: 192.168.1.1:445
```
### Scan first 10000 ports for 192.168.1.1
> ./bnmap.sh -p 192.168.1.1
```
[*] Scanning open ports for 192.168.1.1
        [!] Port open: 192.168.1.1:53
        [!] Port open: 192.168.1.1:80
        [!] Port open: 192.168.1.1:139
        [!] Port open: 192.168.1.1:443
        [!] Port open: 192.168.1.1:445
```

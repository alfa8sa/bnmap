# bnmap
### Bash Network Mapper

Simple and quick network mapper tool coded in bash. It does host discovery through the **ICMP** protocol, finds open ports by using the bash shell `/dev/tcp/..` pseudo-device, and support the **255.255.0.0** subnet mask.

### Help Menu
> ./bnmap.sh -h
```
 _                   
| |__  _ __  _ __ ___   __ _ _ __  
| '_ \| '_ \| '_ \ _ \ / _\ | '_ \ 
| |_) | | | | | | | | | (_| | |_) |
|_.__/|_| |_|_| |_| |_|\__,_| .__/ 
                            |_|    
-------------@alfa8sa--------------


[!] Usage: ./bnmap.sh
-------------------------------------------------------------------------------------
        [-n] Scan network. (Example: -n 192.168.1.0/24)
        [-i] Scan interface. (Example: -i eth0)
        [-p] Scan open ports of a host. [First 10000 ports] (Example: -p 192.168.1.1)
        [-h] Show this help menu.
```
### Basic usage.
> ./bnmap.sh -n 192.168.0.0/16
```
[*] Network:   192.168.0.0
[*] Broadcast: 192.168.255.255
[*] First IP:  192.168.0.1
[*] Last IP:   192.168.255.254

[*] Scanning network: 192.168.0.0/16

        [*] Host 192.168.1.1 ACTIVE
                [!] Port open: 192.168.1.1:53
                [!] Port open: 192.168.1.1:80
                [!] Port open: 192.168.1.1:139
                [!] Port open: 192.168.1.1:443
                [!] Port open: 192.168.1.1:445
        [*] Host 192.168.1.129 ACTIVE
        [*] Host 192.168.1.136 ACTIVE
                [!] Port open: 192.168.1.136:21
                [!] Port open: 192.168.1.136:23
                [!] Port open: 192.168.1.136:80
                [!] Port open: 192.168.1.136:443
                [!] Port open: 192.168.1.136:515
                [!] Port open: 192.168.1.136:631
        [*] Host 192.168.1.175 ACTIVE
        [*] Host 192.168.1.188 ACTIVE
                [!] Port open: 192.168.1.188:135
                [!] Port open: 192.168.1.188:139
                [!] Port open: 192.168.1.188:445
[#                        ] 1% (255 / 65536 hosts)
```

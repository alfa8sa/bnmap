# bnmap
### Bash Network Mapper

Simple and quick network mapper tool coded in bash. It does host discovery by sending an **ICMP** packet, or trying to connect to **TCP** ports **80** and **443**. Once it discovers active hosts, it looks for open ports by using the bash shell `/dev/tcp/..` pseudo-device. It supports a wide variety of network ranges, it is able to scan a network on a given interface, and it can scan multiple networks and hosts from a given file.

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
        [-n] Scan network. (Example: -n 192.168.1.0/24, -n 192.168.1.1-192.168.1.255)
        [-i] Scan interface. (Example: -i eth0, -i eth0 -n 172.16.1.0/24)
        [-f] Scan networks and/or hosts in file. (Example: -f hosts.txt)
        [-p] Scan open ports of a host. [First 10000 ports] (Example: -p 192.168.1.1)
        [-h] Show this help menu.
```
### Basic usage.
> ./bnmap.sh -n 192.168.0.0/16
```
[*] Network:   192.168.0.0
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

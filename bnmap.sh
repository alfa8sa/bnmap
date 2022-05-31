#!/bin/bash

echo -e "
 _                   
| |__  _ __  _ __ ___   __ _ _ __  
| '_ \| '_ \| '_ \ _ \ / _\ | '_ \ 
| |_) | | | | | | | | | (_| | |_) |
|_.__/|_| |_|_| |_| |_|\__,_| .__/ 
                            |_|    
-------------@alfa8sa--------------
"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n[*] Exiting..."
	rm -rf .hosts
	exit 1
}

function helpPanel(){
	
	echo -e "\n[!] Usage: ./bnmap.sh"
	for i in $(seq 1 85); do echo -ne "-"; done
	echo -e "\n\t[-n] Scan network. (Example: -n 192.168.1.0/24, -n 192.168.1.1-192.168.1.255)"
	echo -e "\t[-i] Scan interface. (Example: -i eth0)"
	echo -e "\t[-p] Scan open ports of a host. [First 10000 ports] (Example: -p 192.168.1.1)"
	echo -e "\t[-h] Show this help menu.\n"
	exit 1
}

PROGRESS_BAR_WIDTH=25 
draw_progress_bar() {
	local __value=$1
	local __max=$2
	local __unit=${3:-""}  # if unit is not supplied, do not display it

	if (( $__max < 1 )); then __max=1; fi
	local __percentage=$(( 100 - ($__max*100 - $__value*100) / $__max ))

	local __num_bar=$(( $__percentage * $PROGRESS_BAR_WIDTH / 100 ))


	printf "["
	for b in $(seq 1 $__num_bar); do printf "#"; done
	for s in $(seq 1 $(( $PROGRESS_BAR_WIDTH - $__num_bar ))); do printf " "; done
	printf "] $__percentage%% ($__value / $__max $__unit)\r"
}

function portScan(){
	octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
	ip4="^$octet\\.$octet\\.$octet\\.$octet$"
	if [[ $1 =~ $ip4 ]]; then
		echo -e "\n[*] Scanning open ports for $1"
		draw_progress_bar 1 10000 "ports"
		for port in $(seq 1 10000); do
			timeout 1 bash -c "</dev/tcp/$1/$port" &>/dev/null && echo -e "\r\033[0K\t[!] Port open: $1:$port" && draw_progress_bar $port 10000 "ports" &
		done; wait
	elif [[ $1 == "" ]]; then
		hosts=$(cat .hosts | sort -t . -k 3,3n -k 4,4n -u)
		for host in $hosts; do
			echo -e "\r\033[0K\t[*] Host $host ACTIVE"
			draw_progress_bar $counter $total "hosts"
			for port in $(seq 1 1000); do
				timeout 1 bash -c "</dev/tcp/$host/$port" &>/dev/null && echo -e "\r\033[0K\t\t[!] Port open: $host:$port" && draw_progress_bar $counter $total "hosts" &
			done; wait
		done
		rm -rf .hosts
	else
		echo -e "\n[!] Invalid IPv4 address\n"
	fi
}

function bnmap(){
	
	IFS=. read -r z1 y1 j1 i1 <<< "$1"
	IFS=. read -r z2 y2 j2 i2 <<< "$2"

	((total = (($y2 - $y1) + 1) * (($j2 - $j1) + 1) * ((($i2 + 1) - ($i1 - 1)) + 1)))
	counter=0

	for y in $(seq $y1 $y2); do
		draw_progress_bar $counter $total "hosts"
		for j in $(seq $j1 $j2); do
			draw_progress_bar $counter $total "hosts"
			touch .hosts
			for i in $(seq $i1 $i2); do
				timeout 2 bash -c "ping -c 1 $z1.$y.$j.$i" &>/dev/null && echo $z1.$y.$j.$i >> .hosts &
				timeout 1 bash -c "</dev/tcp/$z1.$y.$j.$i/80" &>/dev/null && echo $z1.$y.$j.$i >> .hosts &
				timeout 1 bash -c "</dev/tcp/$z1.$y.$j.$i/443" &>/dev/null && echo $z1.$y.$j.$i >> .hosts &
			done; wait
			portScan
			let counter=counter+255
		done
	done
}

function check_interface(){
	interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
	if [[ "$interfaces" == *"$1"* ]]; then
		network=$(ip -4 -o a | cut -d ' ' -f 2,7 | grep $1 | awk '{print $2}')
		check_network $network
	else
		interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
		echo -e "\n[!] Invalid interface. Choose one of the following:\n"
		for interface in $interfaces;do
			echo -e "\t$interface"
		done
	fi
}

function check_network(){
	REGEX='(((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))(\/([8-9]|[1-2][0-9]|3[0-2]))([^0-9.]|$)'
	rx='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
	
	if [[ $1 =~ $REGEX ]]; then
		ip_addr=$(echo $1 | awk -F "/" '{print $1}')
		sub_cidr=$(echo $1 | awk -F "/" '{print $2}')

		cidr2mask (){
		   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
		   [ $1 -gt 1 ] && shift $1 || shift
		   echo ${1-0}.${2-0}.${3-0}.${4-0}
		}
		sub_addre=$(cidr2mask $sub_cidr)
		
		IFS=. read -r i1 i2 i3 i4 <<< "$ip_addr"
		IFS=. read -r m1 m2 m3 m4 <<< "$sub_addre"

		first_ip=$((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$(((i4 & m4)+1))
		last_ip=$((i1 & m1 | 255-m1)).$((i2 & m2 | 255-m2)).$((i3 & m3 | 255-m3)).$(((i4 & m4 | 255-m4)-1))
		network_ip=$((i1 & m1)).$((i2 & m2)).$((i3 & m3)).$((i4 & m4))

		echo -e "\n[*] Network:   $network_ip"
		echo -e "[*] Broadcast: $((i1 & m1 | 255-m1)).$((i2 & m2 | 255-m2)).$((i3 & m3 | 255-m3)).$((i4 & m4 | 255-m4))"
		echo -e "[*] First IP:  $first_ip"
		echo -e "[*] Last IP:   $last_ip\n"

		echo -e "[*] Scanning network: $network_ip/$sub_cidr\n"
		bnmap $first_ip $last_ip
	elif [[ $1 =~ ^$rx\.$rx\.$rx\.$rx\-$rx\.$rx\.$rx\.$rx$ ]]; then
		IFS=- read -r first_ip last_ip <<< $1

		IFS=. read -r z1 y1 j1 i1 <<< "$first_ip"
		IFS=. read -r z2 y2 j2 i2 <<< "$last_ip"

		if [ $(expr $z2 - $z1) -lt 0 ] || [ $(expr $y2 - $y1) -lt 0 ] || [ $(expr $j2 - $j1) -lt 0 ] || [ $(expr $i2 - $i1) -lt 0 ]; then
			echo -e "\n[!] Invalid network. Example of valid formats:\n"
			echo -e "\t[*] 192.168.1.1-192.168.1.254"
			echo -e "\t[*] 172.16.0.1-172.31.255.254"
			echo -e "\t[*] 10.0.0.1-10.255.255.254\n"
		else
			echo -e "\n[*] Network:   $1"
			echo -e "[*] First IP:  $first_ip"
			echo -e "[*] Last IP:   $last_ip\n"
	
			echo -e "[*] Scanning network: $1\n"
			bnmap $first_ip $last_ip
		fi
	else
		echo -e "\n[!] Invalid network. Example of valid formats:\n"
		echo -e "\t[*] 192.168.1.0/24"
		echo -e "\t[*] 172.16.0.0/12"
		echo -e "\t[*] 10.0.0.0/8"
		echo -e "\t[*] 192.168.1.1-192.168.1.254"
		echo -e "\t[*] 172.16.0.1-172.31.255.254"
		echo -e "\t[*] 10.0.0.1-10.255.255.254\n"
	fi
}

parameter_counter=0; while getopts "n:i:p:h" arg; do
	case $arg in
		n) check_network $OPTARG;parameter_counter=1;;
		i) check_interface $OPTARG;parameter_counter=1;;
		p) portScan $OPTARG;parameter_counter=1;;
		h) helpPanel;;
	esac
done

if [ $parameter_counter -eq 0 ]; then
	helpPanel
fi

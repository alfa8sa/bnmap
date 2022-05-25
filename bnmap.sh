#!/bin/bash

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n[*] Exiting..."
	rm -rf hosts
	exit 1
}

function helpPanel(){
	echo -e "\n[!] Usage: ./bnmap.sh"
	for i in $(seq 1 85); do echo -ne "-"; done
	echo -e "\n\t[-n] Scan network. (Example: -n 192.168.1.0/24)"
	echo -e "\t[-i] Scan interface. Default subnet mask: 255.255.255.0 (Example: -i eth0)"
	echo -e "\t[-s] Scan interface, but with subnet mask: 255.255.0.0 (Example: -s eth0)"
	echo -e "\t[-p] Scan open ports of a host. [Firts 10000 ports] (Example: -p 192.168.1.1)"
	echo -e "\t[-h] Show this help menu.\n"
	exit 1
}

function portScan(){
	octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
	ip4="^$octet\\.$octet\\.$octet\\.$octet$"
	if [[ $1 =~ $ip4 ]]; then
		echo -e "\n[*] Scanning open ports for $1"
		for port in $(seq 1 10000); do
			timeout 1 bash -c "</dev/tcp/$1/$port" &>/dev/null && echo -e "\t[!] Port open: $1:$port" &
		done; wait
	elif [[ $1 == "" ]]; then
		hosts=$(cat hosts | sort -t . -k 3,3n -k 4,4n)
		for host in $hosts; do
			echo -e "\t[*] Host $host ACTIVE"
			for port in $(seq 1 1000); do
				timeout 1 bash -c "</dev/tcp/$host/$port" &>/dev/null && echo -e "\t\t[!] Port open: $host:$port" &
			done; wait
		done
		rm -rf hosts
	else
		echo -e "\n[!] Invalid IPv4 address\n"
	fi
}

function bnmap(){
	echo -e "\n[*] Scanning network: $1.0/24\n"
	for i in $(seq 1 254); do
		timeout 2 bash -c "ping -c 1 $1.$i" &>/dev/null && echo $1.$i >> hosts &
	done; wait
	portScan
}

function bnmap_16(){
	echo -e "\n[*] Scanning network: $1.0.0/16\n"
	for j in $(seq 0 254); do
		touch hosts
		echo -e "  [*] Scanning network: $1.$j.0/24"
		for i in $(seq 1 254); do
			timeout 3 bash -c "ping -c 1 $1.$j.$i" &>/dev/null && echo $1.$j.$i >> hosts &
		done; wait
		portScan
	done; wait
}

function check_interface(){
	interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
	if [[ "$interfaces" == *"$1"* ]]; then
		if [ $2 == "i" ]; then
			network=$(ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1 | grep $1 | awk '{print $2}' | sed 's/\.[0-9]*$//')
			bnmap $network
		elif [ $2 == "s" ]; then
			network=$(ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1 | grep $1 | awk '{print $2}' | sed 's/\.[0-9]*\.[0-9]*$//')
			bnmap_16 $network
		fi
	else
		interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
		echo -e "\nInvalid interface. Choose one of the following:\n"
		for interface in $interfaces;do
			echo -e "\t$interface"
		done
	fi
}

function check_network(){
	octet="(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])"
	net24="^$octet\\.$octet\\.$octet\\.$octet\\/24$"
	net16="^$octet\\.$octet\\.$octet\\.$octet\\/16$"
	if [[ $1 =~ $net24 ]]; then
		network=$(echo $1 | sed 's/\.[0-9]*\/24$//')
		bnmap $network
	elif [[ $1 =~ $net16 ]]; then
		network=$(echo $1 | sed 's/\.[0-9]*\.[0-9]*\/16$//')
		bnmap_16 $network
	else
		echo -e "\n[!] Invalid network. Valid formats:\n"
		echo -e "\t[*] 192.168.1.0/24"
		echo -e "\t[*] 192.168.0.0/16\n"
	fi
}

parameter_counter=0; while getopts "n:i:s:p:h" arg; do
	case $arg in
		n) check_network $OPTARG;parameter_counter=1;;
		i) check_interface $OPTARG "i";parameter_counter=1;;
		s) check_interface $OPTARG "s";parameter_counter=1;;
		p) portScan $OPTARG;parameter_counter=1;;
		h) helpPanel;;
	esac
done

if [ $parameter_counter -eq 0 ]; then
	helpPanel
fi

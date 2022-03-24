#!/bin/bash

trap ctrl_c INT

function ctrl_c(){
	echo -e "\n[*] Exiting..."
	rm -rf hosts
	exit 1
}

function helpPanel(){
	echo -e "\n[!] Use: ./bnmap.sh"
	for i in $(seq 1 85); do echo -ne "-"; done
	echo -e "\n\t[-i] Scan interface. Default subnet mask: 255.255.255.0 (Example: -i eht0)"
	echo -e "\t[-s] Scan interface, but with subnet mask: 255.255.0.0 (Example: -i eht0)"
	echo -e "\t[-p] Scan open ports of a host. [Firts 10000 ports] (Example: -p 192.168.1.1)"
	echo -e "\t[-h] Show this help menu."
	exit 1
}

function portScan(){
	if [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		echo -e "\n[*] Scanning open ports for $1"
		for port in $(seq 1 10000); do
			timeout 1 bash -c "</dev/tcp/$1/$port" &>/dev/null && echo -e "\t[!] Port open: $1:$port" &
		done; wait
	else
		hosts=$(cat hosts | sort -t . -k 3,3n -k 4,4n)
		for host in $hosts; do
			echo -e "\t[*] Host $host ACTIVE"
			for port in $(seq 1 1000); do
				timeout 1 bash -c "</dev/tcp/$host/$port" &>/dev/null && echo -e "\t\t[!] Port open: $host:$port" &
			done; wait
		done
		rm -rf hosts
	fi
}

function bnmap(){
	network=$(ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1 | grep $1 | awk '{print $2}' | sed 's/\.[0-9]*$//')
	echo -e "\n[*] Scanning network: $network.0/24\n"
	for i in $(seq 1 254); do
		timeout 2 bash -c "ping -c 1 $network.$i" &>/dev/null && echo $network.$i >> hosts &
	done; wait
	portScan
}

function bnmap_16(){
	network=$(ip -4 -o a | cut -d ' ' -f 2,7 | cut -d '/' -f 1 | grep $1 | awk '{print $2}' | sed 's/\.[0-9]*\.[0-9]*$//')
	echo -e "\n[*] Scanning network: $network.0.0/16\n"
	for j in $(seq 1 254); do
		touch hosts
		echo -e "  [*] Scanning network: $network.$j.0/24"
		for i in $(seq 1 254); do
			timeout 2 bash -c "ping -c 1 $network.$j.$i" &>/dev/null && echo $network.$j.$i >> hosts &
		done; wait
		portScan
	done; wait
}

function check_interface(){
	interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
	if [[ "$interfaces" == *"$1"* ]]; then
		if [ $2 == "i" ]; then
			bnmap $1
		elif [ $2 == "s" ]; then
			bnmap_16 $1
		fi
	else
		interfaces=$(/sbin/ip -4 -o a | awk '{print $2}')
		echo -e "\nInvalid interface. Choose one of the following:\n"
		for interface in $interfaces;do
			echo -e "\t$interface"
		done
	fi
}

parameter_counter=0; while getopts "i:s:p:h" arg; do
	case $arg in
		i) check_interface $OPTARG "i";parameter_counter=1;;
		s) check_interface $OPTARG "s";parameter_counter=1;;
		p) portScan $OPTARG;parameter_counter=1;;
		h) helpPanel;;
	esac
done

if [ $parameter_counter -eq 0 ]; then
	helpPanel
fi

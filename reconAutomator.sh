#!/bin/bash

BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
NC=$(tput sgr0)

line_length=$(tput cols)

validate_ipdomain=1
validate_ip=1
validate_whois=1
validate_dnsenum=1
validate_scan=1

validate_ip() {
    local ip=$1
    local stat=1

    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        if [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]; then
            stat=0
        fi
    fi

    return $stat
}

echo -e "${YELLOW}
───────────╔══╗─╔╗────────╔╗
╔╦╦═╦═╦═╦═╦╣╔╗╠╦╣╚╦═╦══╦═╗║╚╦═╦╦╗
║╔╣╩╣═╣╬║║║║╠╣║║║╔╣╬║║║║╬╚╣╔╣╬║╔╝
╚╝╚═╩═╩═╩╩═╩╝╚╩═╩═╩═╩╩╩╩══╩═╩═╩╝${NC}"

resfile="results.txt"

echo "
───────────╔══╗─╔╗────────╔╗
╔╦╦═╦═╦═╦═╦╣╔╗╠╦╣╚╦═╦══╦═╗║╚╦═╦╦╗
║╔╣╩╣═╣╬║║║║╠╣║║║╔╣╬║║║║╬╚╣╔╣╬║╔╝
╚╝╚═╩═╩═╩╩═╩╝╚╩═╩═╩═╩╩╩╩══╩═╩═╩╝" >> $resfile

if [[ $(id -u) -ne 0 ]]; then
    echo -e "${RED}This script requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

while [ "$validate_ipdomain" -eq 1 ];
do
    echo -e "${CYAN}What do you have for me? ip (i) / domain (d):${NC}"
    read -r ip_domain
    if [[ "$ip_domain" == "i" ||
	  "$ip_domain" == "d" ]];
    then
	validate_ipdomain=0
    else
	echo -e "${RED}Invalid option, try again.${NC}\n"
    fi
done

if [ "$ip_domain" == "i" ];
then
    while [ "$validate_ip" -eq 1 ];
    do
	echo -e "${CYAN}IP:${NC}"
	read -r ip	
	if ! validate_ip "$ip";
	then
            echo -e "${RED}Invalid IP address format. Please provide a valid IP address.${NC}\n"
	else
	    validate_ip=0
	fi
    done

    while [ "$validate_whois" -eq 1 ];
    do
	echo -e "${CYAN}Do you want to execute whois? (y/n):${NC}"
	read -r op
	if [[ "$op" == "y" ||
	      "$op" == "n" ]];
	then
	    validate_whois=0
	else
	    echo -e "${RED}Invalid option, try again.${NC}\n"
	fi
    done

    while [ "$validate_dnsenum" -eq 1 ];
    do
	echo -e "${CYAN}Do you want to execute dnsenum? (y/n):${NC}"
	read -r opdn
	if [[ "$opdn" == "y" ||
	      "$opdn" == "n" ]];
	then
	    validate_dnsenum=0
	else
	    echo -e "${RED}Invalid option, try again.${NC}\n"
	fi
    done

    while [ "$validate_scan" -eq 1 ];
    do
	echo -e "${CYAN}Do you want to do a tcp or udp scan? (tcp/udp/both):${NC}"
	read -r scantype
	if [[ "$scantype" == "tcp" ||
	      "$scantype" == "udp" ||
	      "$scan_type" == "both" ]];
	then
	    validate_scan=0
	else
	    echo -e "${RED}Invalid option, try again.${NC}\n"
	fi
     done
	    
     case "$op" in
         "y")
             if [[ "$opdn" == "y" ]];
	     then
                 ./autoInfra.sh "$ip" wy dnsy "$scantype"
             else
                 ./autoInfra.sh "$ip" wy dnsn "$scantype"
             fi
             ;;
         "n")
             if [[ "$opdn" == "n" ]];
	     then
                 ./autoInfra.sh "$ip" wn dnsy "$scantype"
             else
                 ./autoInfra.sh "$ip" wn dnsn "$scantype"
             fi
             ;;
     esac

elif [ "$ip_domain" == "d" ];
then
    ./autoDomain.sh
fi


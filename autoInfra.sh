#!/bin/bash

# Define color variables
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

echo "${YELLOW}
──────╔╗───╔══╗──╔═╗
─────╔╝╚╗──╚╣╠╝──║╔╝
╔══╦╗╠╗╔╬══╗║║╔═╦╝╚╦═╦══╗
║╔╗║║║║║║╔╗║║║║╔╬╗╔╣╔╣╔╗║
║╔╗║╚╝║╚╣╚╝╠╣╠╣║║║║║║║╔╗║
╚╝╚╩══╩═╩══╩══╩╝╚╩╝╚╝╚╝╚╝${NC}"

resfile="results.txt"

if [ $(cat $resfile | wc -l) -gt 0 ];
then
    truncate --size 0 $resfile
fi

echo "
──────╔╗───╔══╗──╔═╗
─────╔╝╚╗──╚╣╠╝──║╔╝
╔══╦╗╠╗╔╬══╗║║╔═╦╝╚╦═╦══╗
║╔╗║║║║║║╔╗║║║║╔╬╗╔╣╔╣╔╗║
║╔╗║╚╝║╚╣╚╝╠╣╠╣║║║║║║║╔╗║
╚╝╚╩══╩═╩══╩══╩╝╚╩╝╚╝╚╝╚╝" >> "$resfile"

out1(){
    padding=$(( (line_length - ${#text}) / 2 ))
    line=$(printf "%*s%s%*s\n" $padding "" "$text" $padding "")
    echo "$line"
}

out2(){
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
    printf "%*s\n" $(((${#line}+$line_length)/2)) "$line" >> "$resfile"
    printf '%*s\n' "$line_length" | tr ' ' '=' >> "$resfile"
}

hostr() {
    text="xxxxxxxxxxxxxxxxxxxx Host xxxxxxxxxxxxxxxxxxxx"
    out1
    line="HOST"
    out2
    host "$1" | tee -a "$resfile"
    echo -e "${GREEN}host done, results.txt for more info${NC}"
}

whoisfunc() {
    text="xxxxxxxxxxxxxxxxxxxx Whois xxxxxxxxxxxxxxxxxxxx"
    out1
    line="WHOIS"
    out2
    whois "$1" >> "$resfile"
    echo -e "${GREEN}whois done, results.txt for more info${NC}"
}

hostup() {
    text="xxxxxxxxxxxxxxxxxxxx is the host up? xxxxxxxxxxxxxxxxxxxx"
    out1
    line="is the host up?"
    out2
    host_status=$(nmap -sn "$1" | grep -i "Host is up")

    if [ -n "$host_status" ]; then
        echo -e "${GREEN}Yep... Host is up${NC}"
        echo "$host_status" >> "$resfile"
    else
        echo -e "${RED}Maybe Windows Blocking ICMP...${NC}"
        host_status2=$(nmap -Pn -PR -n -sn "$1" | grep -i "Host is up")
        if [ -n "$host_status2" ]; then
            echo -e "${GREEN}Yep... Host is up${NC}"
            echo "$host_status2" >> "$resfile"
        else
            echo -e "${RED}Host seems down${NC}"
            echo "No ports open for this host" >> "$resfile"
            echo -e "${RED}Host seems down...${NC}"
            echo "Host seems down..." >> "$resfile"
        fi
    fi
}

handle_port_service() {
    local port=$1

    if grep "$port/tcp" "$resfile" | grep 'open' &> /dev/null;
    then
        echo -e "${GREEN}port $port is open!${NC}"
    else
        echo -e "${RED}port $port is not open.${NC}"
    fi
}

port_service_scan() {
    text="xxxxxxxxxxxxxxxxxxxx Ports & Service Scan xxxxxxxxxxxxxxxxxxxx"
    out1
    line="Ports & Service Scan"
    out2
    nmap_res=$(sudo nmap "$1" -sV | tail -n +4 | head -n -2)
    
    echo "$nmap_res" >> "$resfile"
    echo -e "${MAGENTA}Nmap done, remember that these results are just for common ports.${NC}"
    echo -e "${MAGENTA}For further information, check out results.txt${NC}"

    ports=('21' '22' '25' '53' '80' '110' '111' '137' '138' '139' '143' '445' '587' '993' '995' '2049' '3306' '1433')

    for (( i=0;i<="$(( ${#ports[@]} - 1 ))";i++ ));
    do
	    handle_port_service "${ports[$i]}"
    done
}

dnsenumfunc() {
    text="xxxxxxxxxxxxxxxxxxxx DNSenum xxxxxxxxxxxxxxxxxxxx"
    out1
    line="dnsenum"
    out2
    dnsenum "$1" | tee -a "$resfile"
    echo -e "${GREEN}DNSenum done, results.txt for more info${NC}"
}

if [[ $(id -u) -ne 0 ]]; then
    echo -e "${RED}This script requires root privileges. Please run with sudo.${NC}"
    exit 1
fi

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
    echo -e "${RED}Usage: ./reconAutomator.sh <IP> <whois wy/wn> <dnsenum dnsy/dnsn> <tcp/udp/both>${NC}"
    exit 1
else
    hostr "$1"

    if [[ "$2" == "wy" ]]; then
        whoisfunc "$1"
    fi

    if [[ "$3" == "dnsy" ]]; then
        dnsenumfunc "$1"
    fi

    if [[ "$4" == "tcp" || "$4" == "both" ]]; then
        hostup "$1"
        port_service_scan "$1"
        echo -e "${MAGENTA}ALL DONE... see the results in the results.txt file${NC}"
        exit 1
	
    elif [[ "$4" == "udp" ]]; then
        ############# udp functions 
        echo -e "${MAGENTA}ALL DONE... see the results in the results.txt file${NC}"
        exit 1
    else
        echo -e "${RED}Invalid protocol. Please provide either 'tcp', 'udp', or 'both' as the fourth argument.${NC}"
        exit 1
    fi
fi


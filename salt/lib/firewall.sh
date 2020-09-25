#!/usr/bin/env bash
#
# THIS FILE IS MANAGED BY SALT - DO NOT EDIT MANUALLY
#

#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to manage IPTables firewall rules
#
# Usage:  $0 
#
# Configuration:  
#     The following variables can be set in the /home/sysadmin-tools/firewall-settings.local file
#     Configuration of this file is done automatically by salt.
#
#     # N.B. All arrays are space seperated lists of IP addresses
#     PUBLICHTTPSERVER=ON    # Opens port 80 for the world
#     PRIVATEHTTPSERVER=ON   # Opens port 80 for trusted IPs
#
#     ADDADMINIPS=""  <- Additional IP's that will be given Admin like access
#     ADDADMIN6IPS="" <- Additional IP's that will be given Admin like access
#
#     SYSTEMIPS=""  <- IP addresses of other trusted servers in the network
#     SYSTEM6IPS="" <- IP addresses of other trusted servers in the network
#
#     DHCPV6=yes <- Open port 546 for dhcpv6 traffic
#
#     PUBLICHTTPSERVER=yes   <- Allow public access to Port 80
#     PUBLICHTTPSSERVER=yes  <- Allow public access to Port 443
#     
#     PUBLICSMTPSERVER=yes  <- Allow public access to Port 25
#
#     PRIVATEHTTPSERVER=yes   <- Allow trusted systems and admins access to Port 80
#     PRIVATEHTTPSSERVER=yes  <- Allow trusted systems and admins access to Port 443
#
#     PRIVATESMTPSERVER=yes   <- Allow trusted systems and admins access to Port 25
#
#     POSTGRESSERVER=yes <- Allow trusted systems and admins access to Port 3306
#     
#     Web server IP's for DB servers to allow
#     WEBSERVERIPS=""
#
#     Other settings below can also be overridden in firewall-settings.local
#
set -eu
VERBOSEMODE=true

# Allow slightly more open access to these IP addresses
ADMINIPS="trusted.dogsbody.com"
ADMIN6IPS="trusted6.dogsbody.com"

# Blindly ALLOW connections from these IP addresses
# Not to be used in production but useful for testing without opening up completely
ALLOWALL=""
ALLOW6ALL=""

# Access only to DB port
DATABASEONLYIPS=""

# Blindly BLOCK connections from these IP addresses
# For seriously bad offenders that we don't want on our servers at all
BLOCKALL=""
BLOCK6ALL=""

# Paths to executables and files
IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"
IFCONFIG="/sbin/ifconfig"
WGET="/usr/bin/wget"
IPCMD="/sbin/ip" 

MONITORAPPBEAT="no"

source /home/sysadmin-tools/firewall-settings.local

### Script start ###

function echo_interactive {
    [[ $VERBOSEMODE == true ]] && echo "**** $@ ****"
}

# Docker maintains it's own firewall rules 
if [ -x "$(command -v docker)" ]; then
	echo "Docker is not supported. Please manually maintain IPTables."
	exit 4
fi

echo_interactive "Check we are root"
if [ $LOGNAME != "root" ]
then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

echo_interactive "Get a list of local IP addresses"
if [ ! -z $IPCMD ] && test -f $IPCMD; then
    echo_interactive "Using the $IPCMD command"
    LOCALIPS=`$IPCMD addr | grep "inet " | cut -f 6 -d" " | cut -f 1 -d"/"`
    LOCAL6IPS=`$IPCMD addr | grep "inet6 " | cut -f 6 -d" " | cut -f 1 -d"/"`
elif [ ! -z $IFCONFIG ] && test -f $IFCONFIG; then
    echo_interactive "Using the $IFCONFIG command"
    LOCALIPS=`$IFCONFIG | grep "inet addr" | cut -f 2 -d":" | cut -f 1 -d" "`
    LOCAL6IPS=`$IFCONFIG | grep "inet6 addr" | cut -f 13 -d" " | cut -f 1 -d"/"`
else 
    echo "Error getting local IP's"
    exit 3
fi 

# From now on we want the script to continue through errors
set +eu

echo_interactive "Flush and delete any tables from previous setups"
$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
$IPTABLES -t raw -F
$IPTABLES -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X
$IPTABLES -t raw -X
$IP6TABLES -F
$IP6TABLES -t mangle -F
$IP6TABLES -t raw -F
$IP6TABLES -X
$IP6TABLES -t mangle -X
$IP6TABLES -t raw -X

echo_interactive "Set default policies"
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT
$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD DROP
$IP6TABLES -P OUTPUT ACCEPT

echo_interactive "Create monitor table"
$IPTABLES -N monitor
$IP6TABLES -N monitor

echo_interactive "Create two logging tables"
$IPTABLES -N log-accept
$IPTABLES -A log-accept -j LOG --log-prefix "Packet Accepted:"
$IPTABLES -A log-accept -j ACCEPT
$IPTABLES -N log-drop
$IPTABLES -A log-drop -j LOG --log-prefix "Packet Dropped:"
$IPTABLES -A log-drop -j DROP
$IP6TABLES -N log-accept
$IP6TABLES -A log-accept -j LOG --log-prefix "Packet Accepted:"
$IP6TABLES -A log-accept -j ACCEPT
$IP6TABLES -N log-drop
$IP6TABLES -A log-drop -j LOG --log-prefix "Packet Dropped:"
$IP6TABLES -A log-drop -j DROP

echo_interactive "Create a blacklist to add bad people to"
$IPTABLES -N blacklist
$IPTABLES -A blacklist -m recent --name blacklist --set
$IPTABLES -A blacklist -j log-drop

$IP6TABLES -N blacklist
$IP6TABLES -A blacklist -m recent --name blacklist --set
$IP6TABLES -A blacklist -j log-drop

echo_interactive "Allow connections going through localhost"
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT
$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A OUTPUT -o lo -j ACCEPT

echo_interactive "Blindly allow connections from these IP addresses"
for IP in $ALLOWALL;do
    $IPTABLES -A INPUT -s $IP -j ACCEPT
done
for IP in $ALLOW6ALL;do
    $IP6TABLES -A INPUT -s $IP -j ACCEPT
done

echo_interactive "Blindly block connections from these IP addresses"
for IP in $BLOCKALL;do
    $IPTABLES -A INPUT -s $IP -j DROP
done
for IP in $BLOCK6ALL;do
    $IP6TABLES -A INPUT -s $IP -j DROP
done

echo_interactive "Enable ICMP traffic"
$IPTABLES -A INPUT -p icmp -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -j ACCEPT
$IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT
$IP6TABLES -A OUTPUT -p ipv6-icmp -j ACCEPT

echo_interactive "Allow packets from established connections"
$IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

if [ "$DHCPV6" == "yes" ]; then
    echo_interactive "Opening dhcpv6 client port"
    $IP6TABLES -A INPUT -d fe80::/64 -p udp -m udp --dport 546 -m state --state NEW -j ACCEPT
fi

if [ "$PUBLICHTTPSERVER" == "yes" ]; then
    echo_interactive "Public HTTP Webservers"
    $IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 80 -j ACCEPT
fi
if [ "$PUBLICHTTPSSERVER" == "yes" ]; then
    echo_interactive "Public HTTPS Webservers"
    $IPTABLES -A INPUT -p tcp --dport 443 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 443 -j ACCEPT
fi

if [ "$PUBLICSMTPSERVER" == "yes" ]; then
    echo_interactive "Public SMTP Server"
    $IPTABLES -A INPUT -p tcp --dport 25 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 25 -j ACCEPT
fi

if [ "$PUBLICMAILSERVER" == "yes" ]; then
    echo_interactive "Public Mail Server"
    $IPTABLES -A INPUT -p tcp --dport 587 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 587 -j ACCEPT
    $IPTABLES -A INPUT -p tcp --dport 993 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 993 -j ACCEPT
    $IPTABLES -A INPUT -p tcp --dport 465 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 465 -j ACCEPT
fi

echo_interactive "Setup port knocking for non trusted people"
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8250 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8251 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8252 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8253 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8254 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8255 -m recent --name KNOCK --set -j log-drop
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8256 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8257 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8258 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8259 -m recent --name KNOCK --remove -j DROP
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8260 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8250 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8251 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8252 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8253 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8254 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8255 -m recent --name KNOCK --set -j log-drop
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8256 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8257 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8258 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8259 -m recent --name KNOCK --remove -j DROP
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 8260 -m recent --name KNOCK --remove -j DROP

if [ "$PRIVATEHTTPSERVER" == "yes" ]; then
    echo_interactive "Private HTTP Webservers"
    for IP in $LOCALIPS $ADMINIPS $ADDADMINIPS $SYSTEMIPS; do
        $IPTABLES -A INPUT -p tcp -s $IP --dport 80 -j ACCEPT
    done
    for IP in $LOCAL6IPS $ADMIN6IPS $ADDADMIN6IPS $SYSTEM6IPS; do
        $IP6TABLES -A INPUT -p tcp -s $IP --dport 80 -j ACCEPT
    done
    $IPTABLES -A INPUT -p tcp --dport 80 -j monitor
    $IP6TABLES -A INPUT -p tcp --dport 80 -j monitor
fi
if [ "$PRIVATEHTTPSSERVER" == "yes" ]; then
    echo_interactive "Private HTTPS Webservers"
    for IP in $LOCALIPS $ADMINIPS $ADDADMINIPS $SYSTEMIPS; do
        $IPTABLES -A INPUT -p tcp -s $IP --dport 443 -j ACCEPT
    done
    for IP in $LOCAL6IPS $ADMIN6IPS $ADDADMIN6IPS $SYSTEM6IPS; do
        $IP6TABLES -A INPUT -p tcp -s $IP --dport 443 -j ACCEPT
    done
    $IPTABLES -A INPUT -p tcp --dport 443 -j monitor
    $IP6TABLES -A INPUT -p tcp --dport 443 -j monitor
fi

## SMTP
if [ "$PRIVATESMTPSERVER" == "yes" ]; then
    echo_interactive "Private SMTP Server"
    for IP in $LOCALIPS $ADMINIPS $ADDADMINIPS $SYSTEMIPS; do
        $IPTABLES -A INPUT -p tcp -s $IP --dport 25 -j ACCEPT
    done
    for IP in $LOCAL6IPS $ADMIN6IPS $ADDADMIN6IPS $SYSTEM6IPS; do
        $IP6TABLES -A INPUT -p tcp -s $IP --dport 25 -j ACCEPT
    done
    $IPTABLES -A INPUT -p tcp --dport 25 -j monitor
    $IP6TABLES -A INPUT -p tcp --dport 25 -j monitor
fi

## SSH
echo_interactive "Open SSH access to trusted IP's"
for IP in $LOCALIPS $ADMINIPS $ADDADMINIPS $SYSTEMIPS $BEANSTALKIPS; do
    $IPTABLES -A INPUT -p tcp -s $IP --dport 22 -j ACCEPT
done
for IP in $LOCAL6IPS $ADMIN6IPS $ADDADMIN6IPS; do
    $IP6TABLES -A INPUT -p tcp -s $IP --dport 22 -j ACCEPT
done
$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -m recent --seconds 60 --rcheck --name KNOCK -j log-accept
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -m recent --seconds 60 --rcheck --name KNOCK -j log-accept
$IPTABLES -A INPUT -p tcp --dport 22 -j monitor
$IP6TABLES -A INPUT -p tcp --dport 22 -j monitor

if [ "$PUBLICSSHSERVER" == "yes" ]; then
    echo_interactive "Public SSH Server"
    # Lock new connections out for 10 minutes if too many are made in 30 seconds
    $IPTABLES -N ssh
    $IPTABLES -A ssh -m recent --update --name blacklist --seconds 600 --hitcount 1 -j DROP
    $IPTABLES -A ssh -m recent --set --name sshcount
    $IPTABLES -A ssh -m recent --update --name sshcount --seconds 30 --hitcount 6 -j blacklist
    $IPTABLES -A ssh -j ACCEPT
    $IPTABLES -A INPUT -p tcp --dport 22 -m state --state NEW -j ssh
    $IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT

    $IP6TABLES -N ssh
    $IP6TABLES -A ssh -m recent --update --name blacklist --seconds 600 --hitcount 1 -j DROP
    $IP6TABLES -A ssh -m recent --set --name sshcount
    $IP6TABLES -A ssh -m recent --update --name sshcount --seconds 30 --hitcount 6 -j blacklist
    $IP6TABLES -A ssh -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 22 -m state --state NEW -j ssh
    $IP6TABLES -A INPUT -p tcp --dport 22 -j ACCEPT
fi

## Postgres
if [ "$PUBLICPOSTGRESSERVER" == "yes" ]; then
    echo_interactive "Public Postgres Server"
    $IPTABLES -A INPUT -p tcp --dport 5432 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 5432 -j ACCEPT
fi
if [ "$PRIVATEPOSTGRESSERVER" == "yes" ]; then
    echo_interactive "Private Postgres Server"
    for IP in $LOCALIPS $ADMINIPS $ADDADMINIPS $SYSTEMIPS $DATABASEONLYIPS; do
        $IPTABLES -A INPUT -p tcp -s $IP --dport 5432 -j ACCEPT
    done
    for IP in $LOCAL6IPS $ADMIN6IPS $ADDADMIN6IPS $SYSTEM6IPS; do
        $IP6TABLES -A INPUT -p tcp -s $IP --dport 5432 -j ACCEPT
    done
fi


echo_interactive "Updating monitoring IPs"
if [ "$MONITORAPPBEAT" == "yes" ]; then
    echo_interactive "Get a list of AppBeat IPs"
    # Account for dos line endings
    APPBEATIPS=`curl -s -S https://www.appbeat.io/probes/ipv4 | tr -d '\r'`
    APPBEAT6IPS=`curl -s -S https://www.appbeat.io/probes/ipv6 | tr -d '\r'`
fi

echo_interactive "Flush monitor chain"
$IPTABLES -F monitor
$IP6TABLES -F monitor

echo_interactive "IPv4 monitor chain"
for IP in $PINGDOMIPS $APPBEATIPS $RAPIDSWITCHIPS; do
    $IPTABLES -A monitor -s $IP -j ACCEPT
done

echo_interactive "IPv6 monitor chain"
for IP in $PINGDOM6IPS $APPBEAT6IPS $RAPIDSWITCH6IPS; do
    $IP6TABLES -A monitor -s $IP -j ACCEPT
done

echo_interactive "Updated monitor chains"

echo_interactive "Getting OS version"
if [ -f /etc/os-release ]; then
    source /etc/os-release
elif [ -f /etc/lsb-release ]; then
    source /etc/lsb-release
elif [ -f /etc/redhat-release ]; then
    ID="redhat-derivative"
else
    echo "Warning: Could not find relivent /etc/*-release file."
    echo "  Please update this script for this OS."
fi

echo_interactive "Saving IP tables"
if [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "18.04" ];then
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
elif [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "16.04" ];then
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
elif [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "14.04" ];then
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
elif [ "$ID" == "ubuntu" ] && [ "$VERSION_ID" == "12.04" ];then
    IPTABLESSAVLOC=/etc/iptables.rules
    IP6TABLESSAVLOC=/etc/ip6tables.rules
elif [ "$ID" == "debian" ] && [ "$VERSION_ID" == "8" ];then
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
elif [ "$ID" == "debian" ] && [ "$VERSION_ID" == "7" ];then
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
elif [ "$ID" == "centos" ] && [ "$VERSION_ID" == "7" ];then
    IPTABLESSAVLOC=/etc/sysconfig/iptables
    IP6TABLESSAVLOC=/etc/sysconfig/ip6tables
    # MAKE SURE THAT FIREWALLD HAS BEEN DISABLED AND THAT IPTABLES HAS BEEN ENABLED
elif [ "$ID" == "redhat-derivative" ];then
    IPTABLESSAVLOC=/etc/sysconfig/iptables
    IP6TABLESSAVLOC=/etc/sysconfig/ip6tables
else
    echo "Warning: This script has not been updated for this OS."
    echo "  Please update this script appropriately."
fi

echo_interactive "Saving iptables"
if [ -n "$IPTABLESSAVLOC" ] && [ -n "$IP6TABLESSAVLOC" ];then
    echo "Saving to $IPTABLESSAVLOC & $IP6TABLESSAVLOC"
    iptables-save > $IPTABLESSAVLOC
    ip6tables-save > $IP6TABLESSAVLOC
else
    echo "Warning: The iptables rules were not saved!"
fi


echo_interactive "Script complete"


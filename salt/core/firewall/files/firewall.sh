#!/bin/sh
#
# Manage iptables rules
#
# Configuration:
#   See the /home/sysadmin-tools/firewall-settings.local file for details.
#   On CentOS, make sure that firewalld has been disabled and that iptables has been enabled.
#
# If making changes to this file, check the output when testing the command, because it succeeds
# even if stderr is non-empty. https://github.com/open-contracting/deploy/issues/202

# set -o pipefail needs Bash, but the pipelines are unlikely to fail.
set -eu

# shellcheck disable=SC1091
. /home/sysadmin-tools/firewall-settings.local

echo_verbose() {
    [ "$VERBOSE" = "true" ] && echo "**** $* ****"
}

if [ -x "$(command -v docker)" ] || [ -n "$DOCKER" ]; then
    echo "Docker is not supported. Please configure iptables manually."
    exit 3
fi

echo_verbose "Check user is root"
if [ "$LOGNAME" != "root" ]; then
    echo "User is not root!"
    exit 4
fi

echo_verbose "Get local IP addresses"
if [ -n "$IPCMD" ] && [ -f "$IPCMD" ]; then
    echo_verbose "  ... using the $IPCMD command"
    LOCAL_IPV4=$($IPCMD addr | grep "inet " | cut -d" " -f 6 | cut -d"/" -f 1)
    LOCAL_IPV6=$($IPCMD addr | grep "inet6 " | cut -d" " -f 6 | cut -d"/" -f 1)
elif [ -n "$IFCONFIG" ] && [ -f "$IFCONFIG" ]; then
    echo_verbose "  ... using the $IFCONFIG command"
    LOCAL_IPV4=$($IFCONFIG | grep "inet addr" | cut -d":" -f 2 | cut -d" " -f 1)
    LOCAL_IPV6=$($IFCONFIG | grep "inet6 addr" | cut -d" " -f 13 | cut -d"/" -f 1)
else
    echo "Failed to get local IP addresses!"
    exit 5
fi

echo_verbose "Get OS version"
if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
elif [ -f /etc/lsb-release ]; then
    # shellcheck disable=SC1091
    . /etc/lsb-release
elif [ -f /etc/redhat-release ]; then
    ID="redhat-derivative"
    VERSION_ID=""
else
    echo "Failed to find /etc/*-release file! Please update this script appropriately."
    exit 6
fi

echo_verbose "Get iptables location"
case "${ID}_${VERSION_ID}" in
ubuntu_24.04 | ubuntu_22.04 | ubuntu_20.04 | ubuntu_18.04 | debian_10 | debian_9 | debian_8)
    IPTABLESSAVLOC=/etc/iptables/rules.v4
    IP6TABLESSAVLOC=/etc/iptables/rules.v6
    ;;
centos_7 | redhat-derivative_)
    IPTABLESSAVLOC=/etc/sysconfig/iptables
    IP6TABLESSAVLOC=/etc/sysconfig/ip6tables
    ;;
*)
    echo "Failed to determine iptables location! Please update this script appropriately."
    exit 7
    ;;
esac

if [ "$MONITOR_APPBEAT" = "yes" ]; then
    echo_verbose "Get AppBeat IP addresses"
    # Account for DOS line endings.
    APPBEAT_IPV4=$(curl -sS https://www.appbeat.io/probes/ipv4 | tr -d '\r')
    APPBEAT_IPV6=$(curl -sS https://www.appbeat.io/probes/ipv6 | tr -d '\r')
else
    APPBEAT_IPV4=""
    APPBEAT_IPV6=""
fi

if [ "$MONITOR_PINGDOM" = "yes" ]; then
    echo_verbose "Get Pingdom IP addresses"
    # Account for DOS line endings.
    PINGDOM_IPV4=$(curl -sS https://my.pingdom.com/probes/ipv4 | tr -d '\r')
    PINGDOM_IPV6=$(curl -sS https://my.pingdom.com/probes/ipv6 | tr -d '\r')
else
    PINGDOM_IPV4=""
    PINGDOM_IPV6=""
fi

# We want to continue even if a command fails, because if, for example, a command fails after flushing tables but
# before allowing collections to port 22, recovery becomes much harder.
set +eu

echo_verbose "Flush and delete any tables"
$IPTABLES -F
$IPTABLES -t nat -F
$IPTABLES -t mangle -F
$IPTABLES -t raw -F
$IPTABLES -X
$IPTABLES -t nat -X
$IPTABLES -t mangle -X
$IPTABLES -t raw -X

$IP6TABLES -F
$IP6TABLES -t nat -F
$IP6TABLES -t mangle -F
$IP6TABLES -t raw -F
$IP6TABLES -X
$IP6TABLES -t nat -X
$IP6TABLES -t mangle -X
$IP6TABLES -t raw -X

echo_verbose "Set default policies"
$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

$IP6TABLES -P INPUT DROP
$IP6TABLES -P FORWARD DROP
$IP6TABLES -P OUTPUT ACCEPT

echo_verbose "Create monitor table"
$IPTABLES -N monitor
$IP6TABLES -N monitor

echo_verbose "Create logging tables"
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

echo_verbose "Create deny table"
$IPTABLES -N blacklist
$IPTABLES -A blacklist -m recent --name blacklist --set
$IPTABLES -A blacklist -j log-drop

$IP6TABLES -N blacklist
$IP6TABLES -A blacklist -m recent --name blacklist --set
$IP6TABLES -A blacklist -j log-drop

echo_verbose "Allow traffic on loopback interfaces"
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A OUTPUT -o lo -j ACCEPT

$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A OUTPUT -o lo -j ACCEPT

if [ -n "$ALLOWALL_IPV4" ] || [ -n "$ALLOWALL_IPV6" ]; then
    echo_verbose "Allow ANY connection from given IP addresses"
    for IP in $ALLOWALL_IPV4; do
        $IPTABLES -A INPUT -s "$IP" -j ACCEPT
    done
    for IP in $ALLOWALL_IPV6; do
        $IP6TABLES -A INPUT -s "$IP" -j ACCEPT
    done
fi

if [ -n "$DENYALL_IPV4" ] || [ -n "$DENYALL_IPV6" ]; then
    echo_verbose "Deny ANY connection from given IP addresses"
    for IP in $DENYALL_IPV4; do
        $IPTABLES -A INPUT -s "$IP" -j DROP
    done
    for IP in $DENYALL_IPV6; do
        $IP6TABLES -A INPUT -s "$IP" -j DROP
    done
fi

echo_verbose "Allow traffic using the ICMP protocol"
$IPTABLES -A INPUT -p icmp -j ACCEPT
$IPTABLES -A OUTPUT -p icmp -j ACCEPT

$IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT
$IP6TABLES -A OUTPUT -p ipv6-icmp -j ACCEPT

echo_verbose "Allow traffic from established connections"
$IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IP6TABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

if [ "$PUBLIC_HTTP" = "yes" ]; then
    echo_verbose "Public HTTP server"
    $IPTABLES -A INPUT -p tcp --dport 80 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 80 -j ACCEPT
fi

if [ "$PUBLIC_HTTPS" = "yes" ]; then
    echo_verbose "Public HTTPS server"
    $IPTABLES -A INPUT -p tcp --dport 443 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 443 -j ACCEPT
fi

echo_verbose "Require port knocking for non-trusted sources"
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

echo_verbose "Allow SSH connections from given IP addresses"
for IP in $LOCAL_IPV4 $SSH_IPV4; do
    $IPTABLES -A INPUT -p tcp -s "$IP" --dport 22 -j ACCEPT
done
for IP in $LOCAL_IPV6 $SSH_IPV6; do
    $IP6TABLES -A INPUT -p tcp -s "$IP" --dport 22 -j ACCEPT
done

$IPTABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -m recent --seconds 60 --rcheck --name KNOCK -j log-accept
$IP6TABLES -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -m recent --seconds 60 --rcheck --name KNOCK -j log-accept

$IPTABLES -A INPUT -p tcp --dport 22 -j monitor
$IP6TABLES -A INPUT -p tcp --dport 22 -j monitor

if [ "$PUBLIC_SSH" = "yes" ]; then
    echo_verbose "Public SSH server"
    # Lock new connections out for 10 minutes if 6 connections are made in 30 seconds.
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

if [ "$PUBLIC_POSTGRESQL" = "yes" ]; then
    echo_verbose "Public PostgreSQL server"
    $IPTABLES -A INPUT -p tcp --dport 5432 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 5432 -j ACCEPT
fi

if [ "$PRIVATE_POSTGRESQL" = "yes" ]; then
    echo_verbose "Private PostgreSQL server"
    for IP in $LOCAL_IPV4 $REPLICA_IPV4; do
        $IPTABLES -A INPUT -p tcp -s "$IP" --dport 5432 -j ACCEPT
    done
    for IP in $LOCAL_IPV6 $REPLICA_IPV6; do
        $IP6TABLES -A INPUT -p tcp -s "$IP" --dport 5432 -j ACCEPT
    done
    $IPTABLES -A INPUT -p tcp --dport 5432 -j monitor
    $IP6TABLES -A INPUT -p tcp --dport 5432 -j monitor
fi

if [ "$PUBLIC_TINYPROXY" = "yes" ]; then
    echo_verbose "Public Tinyproxy server"
    $IPTABLES -A INPUT -p tcp --dport 8888 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 8888 -j ACCEPT
fi

if [ "$PRIVATE_PROMETHEUS_CLIENT" = "yes" ]; then
    echo_verbose "Private Prometheus client server"
    for IP in $LOCAL_IPV4 $PROMETHEUS_IPV4; do
        $IPTABLES -A INPUT -p tcp -s "$IP" --dport 7231 -j ACCEPT
    done
    for IP in $LOCAL_IPV6 $PROMETHEUS_IPV6; do
        $IP6TABLES -A INPUT -p tcp -s "$IP" --dport 7231 -j ACCEPT
    done
fi

if [ "$PUBLIC_ELASTICSEARCH" = "yes" ]; then
    echo_verbose "Public Elasticsearch server"
    $IPTABLES -A INPUT -p tcp --dport 9200 -j ACCEPT
    $IP6TABLES -A INPUT -p tcp --dport 9200 -j ACCEPT
fi

echo_verbose "Flush monitor chain"
$IPTABLES -F monitor
$IP6TABLES -F monitor

if [ -n "$APPBEAT_IPV4" ] || [ -n "$APPBEAT_IPV6" ]; then
    echo_verbose "Set monitor chain"
    for IP in $APPBEAT_IPV4; do
        $IPTABLES -A monitor -s "$IP" -j ACCEPT
    done
    for IP in $APPBEAT_IPV6; do
        $IP6TABLES -A monitor -s "$IP" -j ACCEPT
    done
fi

if [ -n "$PINGDOM_IPV4" ] || [ -n "$PINGDOM_IPV6" ]; then
    echo_verbose "Set monitor chain"
    for IP in $PINGDOM_IPV4; do
        $IPTABLES -A monitor -s "$IP" -j ACCEPT
    done
    for IP in $PINGDOM_IPV6; do
        $IP6TABLES -A monitor -s "$IP" -j ACCEPT
    done
fi
echo_verbose "Save iptables to $IPTABLESSAVLOC and $IP6TABLESSAVLOC"
iptables-save > $IPTABLESSAVLOC
ip6tables-save > $IP6TABLESSAVLOC

echo_verbose "Done"

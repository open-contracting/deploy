#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to reset iptables rules.
#
# Usage:  $0

set -euo pipefail

# shellcheck disable=SC1091
source /home/sysadmin-tools/firewall-settings.local

echo "Check user is root"
if [ "$LOGNAME" != "root" ]; then
    echo "User is not root!"
    exit 4
fi

echo "Get iptables location"
case "${ID}_${VERSION_ID}" in
ubuntu_22.04 | ubuntu_20.04 | ubuntu_18.04 | debian_10 | debian_9 | debian_8)
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

$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z
$IPTABLES -t nat -F
$IPTABLES -t nat -X
$IPTABLES -t mangle -F
$IPTABLES -t mangle -X
$IPTABLES -t raw -F
$IPTABLES -t raw -X
$IP6TABLES -P INPUT ACCEPT
$IP6TABLES -P FORWARD ACCEPT
$IP6TABLES -P OUTPUT ACCEPT
$IP6TABLES -F
$IP6TABLES -X
$IP6TABLES -Z
$IP6TABLES -t nat -F
$IP6TABLES -t nat -X
$IP6TABLES -t mangle -F
$IP6TABLES -t mangle -X
$IP6TABLES -t raw -F
$IP6TABLES -t raw -X

echo "Save iptables to $IPTABLESSAVLOC and $IP6TABLESSAVLOC"
iptables-save > $IPTABLESSAVLOC
ip6tables-save > $IP6TABLESSAVLOC

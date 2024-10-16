#!/bin/sh
#
# Description:  Checks whether security patches are available
#
# MIT License
#
# Copyright (c) 2024 Dogsbody Technology Ltd. & James McKinney
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -u

MAILTO="root"
HOST=$(hostname -f)
if [ -f /usr/bin/mail ]; then
    MAIL_CMD="/usr/bin/mail"
else
    MAIL_CMD="/bin/mail"
fi

APTNOTIFY=/usr/lib/update-notifier/apt-check
APTGET=/usr/bin/apt-get
SNAP=/usr/bin/snap
NPM=/usr/bin/npm
PRO=/usr/bin/pro
GREP=/bin/grep
EMAIL=""

# shellcheck disable=SC1091
. /etc/os-release

# Check we are root
if [ "$LOGNAME" != "root" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

#system package update check
if [ "$NAME" = "Amazon Linux" ]; then
    OUTPUT=$(/usr/bin/yum check-update)
    EXITCODE=$?
    if [ $EXITCODE != 0 ]; then
        EMAIL="$EMAIL$OUTPUT\n"
    fi
elif [ "$NAME" = "CentOS Linux" ]; then
    OUTPUT=$(/usr/bin/yum check-update)
    EXITCODE=$?
    if [ $EXITCODE != 0 ]; then
        EMAIL="$EMAIL$OUTPUT\n"
    fi
elif [ "$NAME" = "Ubuntu" ]; then
    OUTPUT=$(/usr/bin/apt-get -qq update)
    EXITCODE=$?
    if [ $EXITCODE != 0 ]; then
        echo "Error updating apt cache" | $MAIL_CMD -s "$HOST: Patches to install" $MAILTO
        exit
    fi

    $PRO status --format=json | $GREP -q '"attached": true'
    EXITCODE=$?
    if [ $EXITCODE = 1 ]; then
        PATCHES=$($APTNOTIFY 2>&1 | cut -d ';' -f 2)
        if [ "$PATCHES" -gt 0 ]; then
            UPDATE1=$($APTNOTIFY --human-readable)
            UPDATE2=$($APTNOTIFY --package-names 2>&1)
            EMAIL="$EMAIL$UPDATE1\n\n$UPDATE2\n"
        fi
    elif [ $EXITCODE = 0 ]; then
        PATCHES=$($APTGET --assume-no -s dist-upgrade | grep -o "^[[:digit:]]\+ upgraded, [[:digit:]]\+ newly installed")
        if [ "$PATCHES" != "0 upgraded, 0 newly installed" ]; then
            UPDATE=$($APTGET dist-upgrade -s --assume-no | sed -n '/The following packages will be upgraded/,/not upgraded/p')
            EMAIL="$EMAIL$UPDATE\n\n"
        fi
    else
        EMAIL="${EMAIL}Error using aptnotifier and apt-get.\n"
    fi
else
    echo "Operating system is not compatible" | $MAIL_CMD -s "$HOST: Patches to install" $MAILTO
    exit
fi

#snap update check
if [ -x $SNAP ] && [ "${SKIPSNAP:-False}" = "False" ]; then
    OUTPUT=$($SNAP refresh --list 2>&1)
    EXITCODE=$?
    if [ "$OUTPUT" != 'All snaps up to date.' ]; then
        if [ $EXITCODE != 0 ]; then
            EMAIL="$EMAIL$OUTPUT"
        else
            PATCHES=$(echo "$OUTPUT" | awk '{ print $1 }' | grep -v Name)
            EMAIL="${EMAIL}Snap updates available:\n$PATCHES\n"
        fi
    fi
fi

#npm update check
if [ -x $NPM ] && [ "${SKIPNPM:-False}" = "False" ]; then
    NPMOUTPUT=$($NPM --location=global outdated --depth=0)
    EXITCODE=$?
    if [ $EXITCODE != 0 ]; then
        EMAIL="${EMAIL}NPM updates available:\n$NPMOUTPUT\n"
    fi
fi

#if any updates they will get emailed to us
if [ "$EMAIL" != "" ]; then
    echo "$EMAIL" | $MAIL_CMD -s "$HOST - $NAME - Patches to install" root
fi

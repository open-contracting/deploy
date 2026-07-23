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

recipient="root"
hostname_output=$(hostname)
if [ -f /usr/bin/mail ]; then
    mail_bin="/usr/bin/mail"
else
    mail_bin="/bin/mail"
fi

aptnotify_bin=/usr/lib/update-notifier/apt-check
aptget_bin=/usr/bin/apt-get
snap_bin=/usr/bin/snap
npm_bin=/usr/bin/npm
body=""

# shellcheck disable=SC1091
. /etc/os-release

if [ "$LOGNAME" != "root" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

if [ "$NAME" = "Amazon Linux" ]; then
    yum_output=$(/usr/bin/yum check-update)
    exitcode=$?
    if [ $exitcode != 0 ]; then
        body="$body$yum_output\n"
    fi
elif [ "$NAME" = "CentOS Linux" ]; then
    yum_output=$(/usr/bin/yum check-update)
    exitcode=$?
    if [ $exitcode != 0 ]; then
        body="$body$yum_output\n"
    fi
elif [ "$NAME" = "Ubuntu" ]; then
    $aptget_bin -qq update
    exitcode=$?
    if [ $exitcode != 0 ]; then
        echo "Error updating apt cache" | $mail_bin -s "$hostname_output: Patches to install" $recipient
        exit
    fi

    /usr/bin/pro status --format=json | grep -q '"attached": true'
    exitcode=$?
    if [ $exitcode = 1 ]; then
        apt_count=$($aptnotify_bin 2>&1 | cut -d ';' -f 2)
        if [ "$apt_count" -gt 0 ]; then
            apt_summary=$($aptnotify_bin --human-readable)
            apt_package_names=$($aptnotify_bin --package-names 2>&1)
            body="$body$apt_summary\n\n$apt_package_names\n"
        fi
    elif [ $exitcode = 0 ]; then
        apt_summary=$($aptget_bin --assume-no -s dist-upgrade | grep -o "^[[:digit:]]\+ upgraded, [[:digit:]]\+ newly installed")
        if [ "$apt_summary" != "0 upgraded, 0 newly installed" ]; then
            apt_package_names=$($aptget_bin dist-upgrade -s --assume-no | sed -n '/The following packages will be upgraded/,/not upgraded/p')
            body="$body$apt_package_names\n\n"
        fi
    else
        body="${body}Error using aptnotifier and apt-get.\n"
    fi
else
    echo "Operating system is not compatible" | $mail_bin -s "$hostname_output: Patches to install" $recipient
    exit
fi

if [ -x $snap_bin ] && [ "${SKIPSNAP:-False}" = "False" ]; then
    snap_output=$($snap_bin refresh --list 2>&1)
    exitcode=$?
    if [ "$snap_output" != 'All snaps up to date.' ]; then
        if [ $exitcode != 0 ]; then
            body="$body$snap_output"
        else
            snap_package_names=$(echo "$snap_output" | awk '{ print $1 }' | grep -v Name)
            body="${body}Snap updates available:\n$snap_package_names\n"
        fi
    fi
fi

if [ -x $npm_bin ] && [ "${SKIPNPM:-False}" = "False" ]; then
    npm_output=$($npm_bin --location=global outdated --depth=0)
    exitcode=$?
    if [ $exitcode != 0 ]; then
        body="${body}NPM updates available:\n$npm_output\n"
    fi
fi

if [ "$body" != "" ]; then
    echo "$body" | $mail_bin -s "$hostname_output - $NAME - Patches to install" root
fi

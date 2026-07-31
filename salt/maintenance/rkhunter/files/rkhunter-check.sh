#!/bin/sh
#
# Description:  A script to monitor RKHunter alerts
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

recipient="root"
hostname_output=$(hostname)
if [ -f /usr/bin/mail ]; then
    mail_bin="/usr/bin/mail"
else
    mail_bin="/bin/mail"
fi

rkhunter_bin="/usr/local/bin/rkhunter"

output=$($rkhunter_bin --nocolors --versioncheck)
exitcode=$?
if [ $exitcode != 0 ]; then
    echo "$output" | $mail_bin -s "$hostname_output: Rootkit Hunter Output" $recipient
fi

output=$($rkhunter_bin --nocolors --update)
exitcode=$?
if [ $exitcode != 0 ]; then
    echo "$output" | $mail_bin -s "$hostname_output: Rootkit Hunter Output" $recipient
fi

output=$($rkhunter_bin --cronjob --report-warnings-only)
exitcode=$?
if [ $exitcode != 0 ]; then
    echo "$output" | $mail_bin -s "$hostname_output: Rootkit Hunter Output" $recipient
fi

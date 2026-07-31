#!/bin/sh
#
# Description:  Shell script to check for lm_sensor alarms

set -eu

recipient="root"
hostname_output=$(hostname)
if [ -f /usr/bin/mail ]; then
    mail_bin="/usr/bin/mail"
else
    mail_bin="/bin/mail"
fi

sensors_output=$(/usr/bin/sensors)

case $sensors_output in
*ALARM*)
    echo "$sensors_output" | $mail_bin -s "$hostname_output: lm_sensors alarm" $recipient
    ;;
esac

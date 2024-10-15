#!/bin/sh
#
# Description:  Shell script to check for lm_sensor alarms

set -eu

MAILTO="root"
HOST=$(hostname)
if [ -f /usr/bin/mail ]; then
    MAIL_CMD="/usr/bin/mail"
else
    MAIL_CMD="/bin/mail"
fi

SENSORS=$(/usr/bin/sensors)

case $SENSORS in
*ALARM*)
    echo "$SENSORS" | $MAIL_CMD -s "$HOST: lm_sensors alarm" $MAILTO
    ;;
esac

#!/bin/sh
#
# Pull the latest emails from Gmail into Redmine
#
# Usage:  /etc/cron.d/redmine
#         */5 * * * * root /bin/bash /home/sysadmin-tools/bin/redmine_cron.sh

API_KEY="{{ pillar.redmine.api_key }}"

COLLECTMAIL=$(curl -Ss "https://crm.open-contracting.org/helpdesk_mailer/get_mail?key=$API_KEY")
COUNTERFILE=/tmp/redmine_cron_error.txt

if [ ! -f $COUNTERFILE ]; then
    echo "0" > $COUNTERFILE
fi

if [ "$COLLECTMAIL" != '{"count":0,"errors":[]}' ]; then
    COUNTER=$(cat $COUNTERFILE)
    COUNTER=$((COUNTER + 1))
    echo $COUNTER > $COUNTERFILE
    # If the script has failed more than 5 times then echo output. This will be sent to root.
    if [ $COUNTER -ge 5 ]; then
        printf "redmine_cron_error\nThe redmine email update cron has failed 5 times successively\n"
    fi
else
    echo "0" > $COUNTERFILE
fi

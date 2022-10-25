#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to pull the latest emails from gmail into redmine
#
# Usage:  /etc/cron.d/redmine
#         */5 * * * * root /bin/bash /home/sysadmin-tools/bin/redmine_cron.sh
#

API_KEY="{{ pillar.redmine.api_key }}"

# This curl triggers the redmine system cron.
COLLECTMAIL=$(curl -Ss "https://crm.open-contracting.org/helpdesk_mailer/get_mail?key=${API_KEY}")
COUNTERFILE=/tmp/readmine_cron_error.txt

# Alert if the cron fails 5 times
if [[ ${COLLECTMAIL} != '{"count":0,"errors":[]}' ]]; then
    COUNTER=$(cat ${COUNTERFILE})
    # Increment the counter.
    echo $((COUNTER++)) > ${COUNTERFILE}
    # If the script has failed more than 5 times then echo output. This will be sent to root.
    if ((COUNTER >= 5)); then
        echo -e "redmine_cron_error\nThe redmine email update cron has failed 5 times successively"
    fi
else
    echo "0" > ${COUNTERFILE}
fi

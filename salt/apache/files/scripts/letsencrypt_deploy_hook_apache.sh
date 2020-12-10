#!/bin/bash
# A script which will run when a Let's Encrypt certificate is renewed successfully. We test the apache configuration, and if it's valid, we reload apache so that the new certificate(s) and key(s) are used.

set -u

A2CTL_BIN="/usr/sbin/apache2ctl"

${A2CTL_BIN} configtest &> /dev/null
APACHE_CONFIGTEST_EC=$?

if [ ${APACHE_CONFIGTEST_EC} != 0 ]; then
    echo "Let's Encrypt deploy hook: Apache config test failed with exit code ${APACHE_CONFIGTEST_EC}. Not reloading." | mail -s "`hostname`: Let's Encrypt renewal apache configtest failure" root
    exit 1
else
    ${A2CTL_BIN} graceful
fi

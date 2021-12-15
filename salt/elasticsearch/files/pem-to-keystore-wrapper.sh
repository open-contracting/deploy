#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  Wrapper script for Apache to renew SSL certificates.
#
# Usage:  MDNotifyCmd: /opt/pem-to-keystore-wrapper.sh
#           This file is executed as the apache user.
#

# Wrapper file to execute pem-to-keystore as root.
sudo /opt/pem-to-keystore.sh

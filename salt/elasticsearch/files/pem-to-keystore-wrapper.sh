#!/usr/bin/env bash

# The MDNotifyCmd command is run as www-data, but `/opt/pem-to-keystore.sh` needs to be run as root.
sudo /opt/pem-to-keystore.sh

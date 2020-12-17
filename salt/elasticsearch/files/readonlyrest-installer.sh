#!/usr/bin/expect -f

# Based on output of:
# autoexpect /usr/share/elasticsearch/bin/elasticsearch-plugin install --silent file:///root/readonlyrest-{{ version }}.zip

set timeout -1
spawn /usr/share/elasticsearch/bin/elasticsearch-plugin install --silent file:///root/readonlyrest-{{ version }}.zip
expect -exact "Continue with installation? \[y/N\]"
send -- "y\r"
expect eof

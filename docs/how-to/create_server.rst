Create a server
===============

Bytemark
--------

#. Make sure you have the deploy token during the whole process
#. Log in to Bytemark
#. Select to create a new server
#. Enter a name and group
#. Traditionally, all our servers are in "York" - select this.
#. Select Performance and disk space
#. Select Ubuntu 18.04 (LTS)
#. Enable Backups every 7 days, on a Thursday, at a random time before 10 (UTC time)
#. For Authentication, select "SSH key (+ Password)" and enter your public key
#. Select "Add This Server"
#. Wait for it to boot up
#. Log in and set a new root password

At this stage details of the server should be logged in a password safe. These details should include both IP addresses, the hostname and the root password. Details for how to do this have not yet been agreed.

#. On the server run:  apt-get install python-msgpack python-concurrent.futures  (This is needed for Salt to work)
#. Add the server to salt-config/roster and salt/top.sls in opendataservices-deploy. If applicable, add the "prometheus-client-apache" state.
#. Locally run:  'salt-ssh <newserver> pkg.upgrade refresh=True dist_upgrade=True' (this can be very slow)
#. Reboot the server
#. Locally run:  'salt-ssh <newserver> state.highstate' (this can be very slow)

Add information about the server to any wiki pages or other places.  Details for how to do this have not yet been agreed.

#. Set up server in Prometheus.


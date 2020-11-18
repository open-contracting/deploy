Connecting to servers with SSH
==============================

.. note::
    Before you can SSH into the OCP servers you first need to upload your SSH public key. See :ref:`salt install page<add-public-key>`.


SSH access on all servers has been locked down using port knocking. 

This means that by default the SSH port blocks all connections.
In order to access the SSH port you first need to Port Knock.
You can do this by sending traffic to port 8255. 

For example using one of the following methods (replacing example.open-contracting.org with the server or IP you're connecting to):

.. code-block:: bash

    curl --silent --connect-timeout 1 example.open-contracting.org:8255
    ssh root@example.open-contracting.org -p 8255

Or by visiting http://example.open-contracting.org:8255 in a browser.

**The above commands will timeout and error** and that is OK, they still work.
No data is returned from port 8255. 

Once you have port knocked you can SSH in as you would any other server.

Please note that there is a 30 second timeout for port knocking, if you take to long to connect you will need to port knock again. 

Once you are connected, the server sees that you're an active connection and keeps the firewall open for you. 


Static IP address
~~~~~~~~~~~~~~~~~

If you have a static IP address and are connecting in often we can whitelist access to your IP address.

Simply add your IP address to the `admin_ips` list in `salt/private/common.sls <https://github.com/open-contracting/deploy-pillar-private/blob/master/common.sls>`_
As well as a note under `IP Info` identifying which user the IP address is for. 

If you are unsure how to do this, feel free to contact sysadmin@open-contracting.org with your IP address and we can whitelist it for you.


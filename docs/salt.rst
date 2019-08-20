Salt
====


The majority of scripts in this repository
are `Salt scripts <https://docs.saltstack.com/en/latest/>`_.

Salt is a configuration management tool.

We use it to script all our standard operations on our servers.

 *  They can be rerun at will.
 *  There are no worries about staff doing manual steps and making a mistake.
 *  Any staff can run them.
 *  They help with knowledge transfer.

We use Salt in the salt-ssh mode. In this mode an agent does not normally run on the servers. Instead, the `salt-ssh` program is run from the staff members computer, makes a SSH connection to the server, and performs any operations it needs to.

Minimum version
---------------

TODO Work out the minimum version of Salt required and document here for people who want to install a suitable version. Link to install pages for common operating systems.


Server Monitoring
=================

Our servers are monitored by `the open source Icinga2 software <https://icinga.com/docs/icinga2/latest/>`_.

The salt scripts in the repository set up the basic Icinga2 software on each server.

They do not:

*  set up a Icinga2 server to use.
*  fully configure the Icinga2 agent on each server to report to the Icinga2 server correctly.

TODO Document how to fully set up the agent on each server so that others can do this.
Document how to set up a server, or more likely, link to existing documentation.

Delete a server
===============

A server is deleted either when a service is moving to a new server (:doc:`create the new server<create_server>`, first), or when a service is being retired.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

#. If appropriate, notify relevant users of the change
#. Remove the server from ``salt/prometheus/files/conf-prometheus.yml``
#. :doc:`Deploy<deploy>` the Prometheus service
#. Remove all occurrences of the server's FQDN and IP address from this repository

If the service is being retired:

#. Remove its configuration from this repository
#. Remove its DNS entries from `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Remove its managed passwords from `LastPass <https://www.lastpass.com>`__
#. Archive its row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Remove its error monitor from `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__, if used
#. Remove its web analytics from `Fathom Analytics <https://app.usefathom.com/>`__, if used
#. Remove its resources from Amazon Web Services, if used
#. Remove its project from Google Cloud Platform, if used
#. Archive its repository on `GitHub <https://ocp-software-handbook.readthedocs.io/en/latest/github/maintainers.html#archive-a-repository>`__, if any

Finally:

#. Securely erase data:

   #. :ref:`Activate the recovery system<recover-server>`
   #. Connect to the server
   #. Open a session in :ref:`tmux<tmux>`. Install ``tmux``, if needed:

      .. code-block:: bash

         apt install tmux

   #. Securely erase data from the relevant device(s), for example:

      .. code-block:: bash

         shred -z -n 1 -v /dev/sda

#. Cancel the server via the :ref:`host<hosting>`'s interface

Delete a server
===============

A server is deleted (decommissioned) either when a service is moving to a new server (:doc:`create the new server<create_server>`, first), or when a service is being retired.

As with other deployment tasks, do the :doc:`setup tasks<setup>` before the steps below.

#. Notify relevant users of the change
#. If the server has :ref:`PostgreSQL<pg-setup-backups>` or :ref:`MySQL<mysql-backups>` backups, use :ref:`pg_dump<pg-recover-backup-universal>` or ``mysqldump``, and manually upload a final backup to the root of the S3 bucket
#. Remove all occurrences of the server's FQDN and IP address from this repository
#. Remove the :ref:`dns` records whose names match the server's FQDN (A, AAAA, SPF)
#. Remove the server's root password from `LastPass <https://www.lastpass.com>`__
#. Shutdown the server via the :ref:`host<hosting>`'s interface

If the service is being retired:

#. Remove it from ``salt/prometheus/files/conf-prometheus.yml``, and :doc:`deploy<deploy>` the Prometheus service
#. Remove its configuration from this repository
#. Remove its :ref:`dns` records
#. Remove its error monitor from `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__, if used
#. Remove its web analytics from `Fathom Analytics <https://app.usefathom.com/>`__, if used
#. Remove its resources from Amazon Web Services, if used
#. Remove its project from Google Cloud Platform, if used
#. Archive its repository on `GitHub <https://ocp-software-handbook.readthedocs.io/en/latest/github/maintainers.html#archive-a-repository>`__, if any
#. Archive its row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet

Finally (wait two weeks to be sure files were migrated):

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

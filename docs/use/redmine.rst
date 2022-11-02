Redmine
=======

Run SQL commands
----------------

Via shell
~~~~~~~~~

#. Connect to the server as the ``report_user`` user:

   .. code-block:: bash

      curl --silent --connect-timeout 1 crm.open-contracting.org:8255 || true
      ssh report_user@crm.open-contracting.org

#. Open a MySQL console:

   .. code-block:: bash

      mysql redmine -u report -p

Via application
~~~~~~~~~~~~~~~

#. Create an SSH tunnel as the ``report_user`` user, to forward MySQL's port 3306 to a port number of your preference, for example:

   .. code-block:: bash

      curl --connect-timeout 1 http://crm.open-contracting.org:8255/
      ssh -N report_user@crm.open-contracting.org -L 3307:localhost:3306

#. Use any of the applications described at :doc:`databases`. The general configuration is:

   Host
     localhost
   Port
     3307 (as above)
   Database
     redmine
   User
     report

   If using the ``mysql`` command, set the protocol:

   .. code-block:: bash

      mysql redmine --host localhost --port 3307 --user report --protocol TCP -p

.. _redmine-console:

Open interactive consoles
-------------------------

#. Connect to the server as the ``redmine`` user:

   .. code-block:: bash

      curl --silent --connect-timeout 1 crm.open-contracting.org:8255 || true
      ssh redmine@crm.open-contracting.org

#. Change to the Redmine application's directory:

   .. code-block:: bash

      cd /home/redmine/public_html

#. Open a Rails console:

   .. code-block:: bash

      bundle exec rails console --environment=production

#. Or, open a MySQL console (password in ``config/database.yml``):

   .. code-block:: bash

      bundle exec rails dbconsole --environment=production

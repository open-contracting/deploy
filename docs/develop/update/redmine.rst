Configure Redmine
=================

Redmine requires :doc:`MySQL<mysql>`__ and :ref:`mod_passenger for Apache<apache-modules>`__.

Check `Redmine's documentation for supported Ruby and MySQL versions <https://www.redmine.org/projects/redmine/wiki/redmineinstall>`__.

Add basic configuration
-----------------------

In the service's Pillar file, add, for example:

.. code-block:: yaml
   
   redmine:
     user: redmine
     svn:
       branch: 5.0-stable
       revision: 21783
     config: redmine
     database:
       name: redmine
       user: redmine

And in the servers private Pillar file:

.. code-block:: yaml

   redmine:
     database:
       password: "PASSWORD"

This will:

-  Create a ``redmine`` user.
-  Deploy the Redmine SVN repository using the ``branch`` and ``revision`` under ``redmine``.
-  Upload the ``config`` file sourced in ``salt/redmine/files/``.
-  Configure Redmine with the ``database`` details.

Add plugins
-----------

.. code-block:: yaml

   redmine:
     plugins:
       - redmine_agile
       - redmine_checklists
       - redmine_contacts
       - redmine_contacts_helpdesk
       - view_customize

This will deploy each ``plugin`` sourced in ``salt/private/files/redmine-plugins/``.

Install dependencies
--------------------

The following commands install Redmine dependencies and database structure changes. These commands need running whenever Redmine and it's plugins are updated.

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 ocp16.open-contracting.org:8255 || true
      ssh root@ocp16.open-contracting.org

#. Change to the Redmine site directory, for example:

   .. code-block:: bash

      cd /home/redmine/public_html

#. Install Ruby Gem packages:

   .. code-block:: bash

      BUNDLER_WITHOUT="development test" bundle install

#. Generate Redmine token (only run on the first install):

   .. code-block:: bash

      bundle exec rake generate_secret_token

#. Update database to match the code base:

   .. code-block:: bash

      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake redmine:plugins:migrate


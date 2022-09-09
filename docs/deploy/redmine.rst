Redmine tasks
=============

Upgrade the Redmine service
---------------------------

Check `Redmine's documentation for supported Ruby and MySQL versions <https://www.redmine.org/projects/redmine/wiki/redmineinstall>`__.

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 ocp16.open-contracting.org:8255 || true
      ssh root@ocp16.open-contracting.org

#. Change to the Redmine application's directory:

   .. code-block:: bash

      cd /home/redmine/public_html

#. Install Redmine dependencies:

   .. code-block:: bash

      BUNDLER_WITHOUT="development test" bundle install

#. Generate Redmine token (only on first install):

   .. code-block:: bash

      bundle exec rake generate_secret_token

#. Run database migrations:

   .. code-block:: bash

      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake redmine:plugins:migrate

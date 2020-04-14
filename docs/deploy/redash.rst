Redash tasks
============

Setting up a new Redash server
------------------------------

To set up a new Redash server, there are some steps that must be taken that aren't done in Salt. Instead they are documented here.

(It would have taken a lot of work to do the Salt correctly, and given how rarely they would be used it was felt this was fine.)

1. Make directory
~~~~~~~~~~~~~~~~~

.. code-block:: bash

    mkdir -p /opt/redash/postgres-data

Once this is made, the user permissions on it must not be changed. So it is in here, and not a salt instruction.


2. Create a config file.
~~~~~~~~~~~~~~~~~~~~~~~~

`Look in the setup script <https://github.com/getredash/setup/blob/master/setup.sh>`__ - we will follow the instructions in the `create_config` function.

Start by setting

.. code-block:: bash

    REDASH_BASE_PATH=/opt/redash

Then run the commands from the `create_config` function by hand (ignore stuff in  `if [[ -e $REDASH_BASE_PATH/env ]]; then` )

If migrating from an old server, you must now edit `/opt/redash/env` and set `REDASH_COOKIE_SECRET` and `REDASH_SECRET_KEY` to be the same as the old server.

3. Create a Docker compose file
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


`Look in the setup script <https://github.com/getredash/setup/blob/master/setup.sh>`__ -  we will follow the instructions in the `setup_compose` function.

Start by setting

.. code-block:: bash

    REDASH_BASE_PATH=/opt/redash

Then run the  commands from the `setup_compose` function by hand, starting at the top and until you get to commands that echo stuff to profile.

4. Edit Docker Compose file to move port
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Edit `/opt/redash/docker-compose.yml`

Find machine `nginx` and edit port to `9090:80`


5. Finally start app - if totally new server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



.. code-block:: bash

    cd /opt/redash/
    docker-compose run --rm server create_db
    docker-compose up -d

5. Finally, start app - If moving from an old server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this case, we must migrate the old database.

.. code-block:: bash

    cd /opt/redash/

You must edit the `docker-compose.yml` file to make the Postgres server available. To the `postgres` server add:

.. code-block:: bash

    cd /opt/redash/
    ports:
      - "5432:5432"

Run

.. code-block:: bash

    docker-compose up -d

Dump the Postgres database on the old server and import it to the new server.
Look in `/opt/redash/env` for database settings to use in new server.

Now for any upgrades run

.. code-block:: bash

    docker-compose run --rm server create_db

Edit `docker-compose.yml` and remove the `postgres` port (for better security). To make that change active, restart Redash.



Upgrading Redash
----------------

Follow `a usual Docker upgrade process. <https://redash.io/help/open-source/admin-guide/how-to-upgrade>`__


Configuration Setup
-------------------

To do this, edit `/opt/redash/env` and then restart (see below).

We use the permissions feature, set:

.. code-block:: bash

    REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL=true

For email sending, see `Redash docs <https://redash.io/help/open-source/setup#Mail-Configuration>`__. Make sure you set `REDASH_HOST` too.

(note: the `send_test_mail` command did not work for me but just putting my email in "Forgotten Password" did.)

Restarting Redash
-----------------

If you have just edited the configuration, for example.

.. code-block:: bash

    cd /opt/redash/
    docker-compose stop
    docker-compose up -d

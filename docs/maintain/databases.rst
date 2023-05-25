Maintain PostgreSQL
===================

Troubleshoot
------------

Check the log file, ``/var/log/postgresql/postgresql-11-main.log``, if debugging an unscheduled restart of the ``postgres`` service, for example.

Find slow queries
~~~~~~~~~~~~~~~~~

Use the `pg_stat_statements <https://www.postgresql.org/docs/current/pgstatstatements.html>`__ extension. For example:

.. code-block:: sql

   SELECT
       usename,
       substring(query, 1, 80) AS short_query,
       round(total_time::numeric, 2) AS total_time,
       calls,
       round(mean_time::numeric, 2) AS mean,
       round((100 * total_time /
       sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
   FROM pg_stat_statements s
   INNER JOIN pg_user u ON s.userid = u.usesysid
   ORDER BY total_time DESC
   LIMIT 20;

To display the full query, you might prefer to switch to unaligned output mode (``\a``):

.. code-block:: sql

   SELECT
       usename,
       query,
       round(total_time::numeric, 2) AS total_time,
       calls,
       round(mean_time::numeric, 2) AS mean,
       round((100 * total_time /
       sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
   FROM pg_stat_statements s
   INNER JOIN pg_user u ON s.userid = u.usesysid
   ORDER BY total_time DESC
   LIMIT 20;

To reset the statistics:

.. code-block:: sql

   SELECT pg_stat_statements_reset();

Reference: `Tracking down slow queries in PostgreSQL <https://www.cybertec-postgresql.com/en/pg_stat_statements-the-way-i-like-it/>`__

Control access
--------------

Each individual should have a personal account, and each service should have a service account.

Add a user
~~~~~~~~~~

#. Add, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/features/password-generator>`__ and ``USERNAME`` with a recognizable username (for example, the lowercase first initial and family name of the person, like ``jdoe``):

   .. code-block:: yaml

      postgres:
        users:
          # me@example.com
          USERNAME:
            password: "PASSWORD"

#. Assign the user to groups. For example, the ``kingfisher-process`` target has the groups:

   kingfisher_process_read
     ``SELECT`` on all tables in schema ``public``
   kingfisher_summarize_read
     ``SELECT`` on all tables in schema created by Kingfisher Summarize

   .. code-block:: yaml
      :emphasize-lines: 6-8

      postgres:
        users:
          # me@example.com
          USERNAME:
            password: "PASSWORD"
            groups:
              - kingfisher_process_read
              - kingfisher_summarize_read

#. :doc:`Deploy the service<../deploy/deploy>`

Update a password
~~~~~~~~~~~~~~~~~

#. Update the private Pillar file, for example:

   .. code-block:: yaml
      :emphasize-lines: 5

      postgres:
        users:
          # me@example.com
          USERNAME:
            password: "PASSWORD"

#. :doc:`Deploy the service<../deploy/deploy>`

#. Notify the contact at the email address in the comment

Delete a user
~~~~~~~~~~~~~

#. Delete the user from the private Pillar file

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
      ssh root@process.kingfisher.open-contracting.org

#. Attempt to drop the user as the ``postgres`` user, for example:

   .. code-block:: bash

      su - postgres -c 'psql ocdskingfisherprocess -c "DROP ROLE ocdskfpguest;"'

#. If you see a message like:

   .. code-block:: none

      ERROR:  role "ocdskfpguest" cannot be dropped because some objects depend on it
      DETAIL:  privileges for table …
      …
      and 1234 other objects (see server log for list)

#. Open the server log, and search for the relevant ``DROP ROLE`` statement (after running the command below, press ``/``, type ``DROP ROLE``, press Enter, and press ``n`` until you match the relevant statement):

   .. code-block:: bash

      less /var/log/postgresql/postgresql-11-main.log

#. If all the objects listed after ``DETAIL:`` in the server log can be dropped (press Space to scroll forward), then press ``q`` to quit ``less`` and open a SQL terminal as the ``postgres`` user:

   .. code-block:: bash

      su - postgres -c 'psql ocdskingfisherprocess'

#. Finally, drop the user:

   .. code-block:: sql

      REASSIGN OWNED BY ocdskfpguest TO anotheruser;
      DROP OWNED BY ocdskfpguest;
      DROP ROLE ocdskfpguest;

Check privileges
~~~~~~~~~~~~~~~~

List users and groups:

.. code-block:: none

   \du

Find unexpected database ``CREATE`` privileges:

.. code-block:: sql

   SELECT usename, string_agg(datname, ', ' ORDER BY datname)
   FROM pg_user
   CROSS JOIN pg_database
   WHERE
       usename NOT IN ('postgres') AND
       has_database_privilege(usename, datname, 'CREATE') AND
       NOT (usename = 'kingfisher_summarize' AND datname = 'ocdskingfisherprocess')
   GROUP BY usename
   ORDER BY usename;

Find unexpected schema ``CREATE`` privileges:

.. code-block:: sql

   SELECT usename, string_agg(nspname, ', ' ORDER BY nspname)
   FROM pg_user
   CROSS JOIN pg_namespace
   WHERE
       usename NOT IN ('postgres') AND
       has_schema_privilege(usename, nspname, 'CREATE') AND
       NOT (usename = 'kingfisher_process' AND nspname = 'public') AND
       NOT (usename = 'kingfisher_summarize' AND nspname LIKE 'view_data_%')
   GROUP BY usename
   ORDER BY usename;

Find unexpected schema ``USAGE`` privileges:

.. code-block:: sql

   SELECT usename, string_agg(nspname, ', ' ORDER BY nspname)
   FROM pg_user
   CROSS JOIN pg_namespace
   WHERE
       usename NOT IN ('postgres') AND
       nspname NOT IN ('information_schema', 'pg_catalog', 'reference', 'summaries') AND
       has_schema_privilege(usename, nspname, 'USAGE') AND
       NOT (usename = 'kingfisher_summarize' AND nspname LIKE 'view_data_%') AND
       NOT (pg_has_role(usename, 'kingfisher_process_read', 'MEMBER') AND nspname = 'public') AND
       NOT (pg_has_role(usename, 'kingfisher_summarize_read', 'MEMBER') AND nspname LIKE 'view_data_%')
   GROUP BY usename
   ORDER BY usename;

Find unexpected table non ``SELECT`` privileges:

.. code-block:: sql

   SELECT usename, nspname, string_agg(relname, ', ' ORDER BY relname)
   FROM pg_user
   CROSS JOIN pg_class c
   JOIN pg_namespace n ON c.relnamespace = n.oid
   WHERE
       usename NOT IN ('postgres') AND
       nspname NOT IN ('pg_toast') AND
       relname NOT IN ('pg_settings') AND
       has_table_privilege(usename, c.oid, 'INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') AND
       NOT (usename = 'kingfisher_process' AND nspname = 'public') AND
       NOT (usename = 'kingfisher_summarize' AND nspname LIKE 'view_data_%')
   GROUP BY usename, nspname
   ORDER BY usename, nspname;

Reference: `System Information Functions <https://www.postgresql.org/docs/current/functions-info.html>`__ for functions like ``has_schema_privilege``

Improve performance
-------------------

Tune settings
~~~~~~~~~~~~~

-  :doc:`Connect to the server<../use/ssh>`
-  Change to the ``postgres`` user:

   .. code-block:: bash

      su - postgres

-  Download the ``postgresqltuner.sql`` file (if not available):

   .. code-block:: bash

      curl -O https://raw.githubusercontent.com/jfcoz/postgresqltuner/master/postgresqltuner.pl

-  Make the ``postgresqltuner.sql`` file executable:

   .. code-block:: bash

      chmod ug+x postgresqltuner.pl

-  Run the ``postgresqltuner.sql`` file:

   .. code-block:: bash

      ./postgresqltuner.sql --ssd

Under "Configuration advice", address "HIGH" and "MEDIUM" recommendations.

Reference: `Tuning Your PostgreSQL Server <https://wiki.postgresql.org/wiki/Tuning_Your_PostgreSQL_Server>`__

Reference: `Slow Query Questions <https://wiki.postgresql.org/wiki/Slow_Query_Questions>`__

.. _pg-stat-all-tables:

Check autovacuum statistics
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sql

   SELECT
       nspname,
       s.relname,
       reltuples,
       n_live_tup::real,
       n_dead_tup::real,
       TRUNC(n_dead_tup / GREATEST(reltuples::numeric, 1) * 100, 2) AS percent,
       last_autovacuum,
       last_autoanalyze
   FROM pg_stat_all_tables s
   JOIN pg_class c ON relid = c.oid
   JOIN pg_namespace ON relnamespace = pg_namespace.oid
   ORDER BY percent DESC, last_autovacuum;

See the `pg_stat_all_tables <https://www.postgresql.org/docs/current/monitoring-stats.html#PG-STAT-ALL-TABLES-VIEW>`__ table's documentation.

To get the table related to a ``pg_toast_*`` table, take the number after ``pg_toast_``, and run, for example:

.. code-block:: sql

   SELECT '16712'::regclass;

Check usage
-----------

Explore database
~~~~~~~~~~~~~~~~

List databases:

.. code-block:: none

   \l

List schemas:

.. code-block:: none

   \dn

List tables, views and sequences in the ``public`` schema:

.. code-block:: none

   \d

List tables, indexes, views and sequences in the ``public`` schema:

.. code-block:: none

   \dtivs

To list tables, views and/or sequences in a specific schema, append, for example, ``reference.*`` – or append ``*.*`` for all schema.

You can use the ``psql`` command's ``-E`` (``--echo-hidden``) `flag <https://www.postgresql.org/docs/current/app-psql.html#R1-APP-PSQL-3>`__ to echo the queries generated by the backslash commands.

Check drive usage
~~~~~~~~~~~~~~~~~

Get all database sizes:

.. code-block:: none

   \l+

Get all schema sizes:

.. code-block:: sql

   SELECT
       schema_name,
       schema_size,
       pg_size_pretty(schema_size),
       TRUNC(schema_size::numeric / pg_database_size(current_database()) * 100, 2) AS percent
   FROM (
       SELECT
           nspname AS schema_name,
           SUM(pg_relation_size(c.oid))::bigint AS schema_size
       FROM pg_class c
       JOIN pg_namespace n ON c.relnamespace = n.oid
       GROUP BY schema_name
   ) t
   ORDER BY schema_size DESC;

Get relation sizes in the ``public`` schema:

.. code-block:: none

   \dtis+

To get relation sizes in a specific schema, append, for example, ``reference.*`` – or append ``*.*`` for all schema.

See the `Database Object Size Functions <https://www.postgresql.org/docs/current/functions-admin.html#FUNCTIONS-ADMIN-DBSIZE>`__ documentation.

.. _pg-stat-activity:

Show running queries
~~~~~~~~~~~~~~~~~~~~

Show running queries:

.. code-block:: sql

   SELECT pid, client_addr, usename, state, wait_event_type, NOW() - query_start AS time, query
   FROM pg_stat_activity
   WHERE query <> ''
   ORDER BY time DESC;

Stop a query, replacing ``PID`` with the query's ``pid``:

.. code-block:: sql

   SELECT pg_cancel_backend(PID)

See the `pg_stat_activity <https://www.postgresql.org/docs/current/monitoring-stats.html#PG-STAT-ACTIVITY-VIEW>`__ table's documentation.

Find unexpected schema:

.. code-block:: sql

   SELECT nspname
   FROM pg_namespace
   WHERE
       nspname NOT LIKE 'pg_temp_%' AND
       nspname NOT LIKE 'pg_toast_temp_%' AND
       nspname NOT LIKE 'view_data_%' AND
       nspname NOT IN (
           'information_schema',
           'pg_catalog',
           'pg_toast',
           'public',
           'reference',
           'summaries'
       );

Find unexpected tables in the public schema:

.. code-block:: sql

   SELECT relname
   FROM pg_class c
   JOIN pg_namespace n ON c.relnamespace = n.oid
   WHERE
       nspname = 'public' AND
       -- Ignore sequences and indices
       relkind NOT IN ('S', 'i') AND
       relname NOT IN (
           -- Kingfisher Process tables
           'collection',
           'collection_file',
           'collection_file_item',
           'collection_note',
           'compiled_release',
           'data',
           'package_data',
           'record',
           'record_check',
           'release',
           'release_check',
           -- To be removed in future versions
           'alembic_version',
           'record_check_error',
           'release_check_error',
           'transform_upgrade_1_0_to_1_1_status_record',
           'transform_upgrade_1_0_to_1_1_status_release',
           -- https://www.postgresql.org/docs/current/pgstatstatements.html
           'pg_stat_statements',
           -- https://www.postgresql.org/docs/current/tablefunc.html
           'tablefunc_crosstab_2',
           'tablefunc_crosstab_3',
           'tablefunc_crosstab_4'
       );

.. _pg-recover-backup:

Restore from backup
-------------------

PostgreSQL databases are backed up offsite. Backup and restoration are managed by `pgBackRest <https://pgbackrest.org/>`__.
These are the main commands for working with pgbackrest.

.. note::

   For more information on setting up backups, see :ref:`pg-setup-backups`.

The stanza name is defined in pillar ``postgres:backup:stanza``.
You can also find it in the pgbackrest config ``/etc/pgbackrest/pgbackrest.conf``.

View current backups:

.. code-block:: bash

   pgbackrest info --stanza=example

Restore from backup:

.. code-block:: bash

   pgbackrest restore --stanza=example --delta

Restore specific backup by timestamp:

.. code-block:: bash

   pgbackrest restore --stanza=example --set=20210315-145357F_20210315-145459I --delta

The ``--delta`` flag saves time when restoring by checking file hashes and only restoring the files it needs to.
If you want to restore every file from the backup, for example if you are restoring to a new server, it may be quicker to not use deltas.

You can run a full restore following this process:

.. code-block:: bash

   rm -rf /var/lib/postgresql/11/main
   mkdir /var/lib/postgresql/11/main
   pgbackrest restore --stanza=example

.. _pg-recover-replica:

Recover the replica
-------------------

If replication breaks or the replica server goes offline, you must recover the replica, in two stages: mitigate the downtime, and fix the replication.

Mitigate downtime
~~~~~~~~~~~~~~~~~

#. :ref:`Enable public access<pg-public-access>` to the PostgreSQL service on the main server, by modifying its Pillar file:

   .. code-block:: yaml

      postgres:
        public_access: True

   For example, for the ``kingfisher-process`` target, modify the ``pillar/kingfisher.sls`` file.

#. :doc:`Deploy the main server<../../deploy/deploy>`
#. Update DNS records:

   #. Login to `GoDaddy <https://sso.godaddy.com>`__
   #. If access was delegated, open `Delegate Access <https://account.godaddy.com/access>`__ and click the *Access Now* button
   #. Open `DNS Management <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__ for open-contracting.org
   #. Update the replica's CNAME record to point to the main server's A record: for example, point ``postgres-readonly`` to ``process1.kingfisher``
   #. Wait for the changes to propagate, which depends on the original TTL value

Fix replication
~~~~~~~~~~~~~~~

#. Log into the replica server

#. Stop PostgreSQL if it is still running

   .. code-block:: bash

      systemctl stop postgres.service

#. Download the latest database or a backup from a specific point in time

   In this example I'm restoring ``kingfisher``, to restore a different instance, replace ``kingfisher`` with the value set in pillar ``postgres:backup:stanza``.
   pgbackrest is pre-configured to restore the replication configuration (``/var/lib/postgresql/11/main/recovery.conf``).

   .. code-block:: bash

      pgbackrest --stanza=kingfisher --type=standby --delta restore

   .. note::

      See :ref:`pg-recover-backup` for more information on the pgbackrest restore function.

#. Start PostgreSQL and monitor

   You should see messages about recovering from WAL files in the logs.

   .. code-block:: bash

      systemctl start postgres.service
      tail -f /var/log/postgresql/postgresql-11-main.log

If all else fails, you can fallback to rebuilding the replica. See :ref:`pg-setup-replication`.

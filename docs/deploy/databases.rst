Maintain a database
===================

Explore
-------

List databases:

.. code-block:: sql

   \l

List schemas:

.. code-block:: sql

   \dn

List tables, views and sequences:

.. code-block:: sql

   \d

List tables, indexes, views and sequences:

.. code-block:: sql

   \dtivs

To list tables, views and/or sequences in a specific schema, append, for example, ``views.*``.

Check disk usage
----------------

Get all database sizes:

.. code-block:: sql

   \l+

Get relation sizes in the ``public`` schema:

.. code-block:: sql

   \dtis+

Get relation sizes in a specific schema, for example:

.. code-block:: sql

   \dtis+ views.*

Get all relation sizes:

.. code-block:: sql

   \dtis+ *.*

Get all schema sizes:

.. code-block:: sql

   SELECT schema_name,
          schema_size,
          pg_size_pretty(schema_size),
          TRUNC((schema_size::numeric / pg_database_size(current_database())) * 100, 2) AS percent
   FROM (
     SELECT pg_catalog.pg_namespace.nspname AS schema_name,
            SUM(pg_relation_size(pg_catalog.pg_class.oid))::bigint AS schema_size
     FROM pg_catalog.pg_class
     JOIN pg_catalog.pg_namespace ON relnamespace = pg_catalog.pg_namespace.oid
     GROUP BY schema_name
   ) t
   ORDER BY schema_size DESC;

Other operations
----------------

Show running queries:

.. code-block:: sql

   SELECT pid, client_addr, usename, state, wait_event_type, NOW() - query_start AS time, query
   FROM pg_stat_activity
   WHERE query <> ''
   ORDER BY time DESC;

Show autovacuum statistics:

.. code-block:: sql

   SELECT nspname,
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

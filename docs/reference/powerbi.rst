Power BI
========

{spider} and {spider}_clean tables
----------------------------------

`Kingfisher Collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__ crawls data sources, and inserts OCDS data into SQL tables. The schema is:

.. code-block:: sql

   CREATE TABLE myspider (
       data jsonb
   );
   CREATE INDEX idx_myspider ON myspider USING btree (((data ->> 'date'::text)));

Cardinal's `prepare command <https://cardinal.readthedocs.io/en/latest/cli/prepare.html>`__ corrects quality issues and inserts corrected data into ``{spider}_clean`` tables with the same schema.

{spider}_result tables
----------------------

Cardinal's `indicators command <https://cardinal.readthedocs.io/en/latest/cli/indicators/index.html>`__ calculates red flags and inserts results into tables. The schema is:

.. literalinclude:: ../../salt/kingfisher/collect/files/sql/result.sql
   :language: sql
   :start-after: CREATE
   :end-before: );

-  An indicator triggers at most once per entity (``ocid``, ``buyer_id``, ``procuring_entity_id`` or ``tenderer_id``). However, we “spread” the non-OCID results across multiple contracting processes. So, the unique key (if we were to add one) would be (``ocid``, ``code``, ``buyer_id``, ``procuring_entity_id``, ``tenderer_id``).

-  Each row is about only one entity. For example, if a contracting process is flagged (``ocid``) and the same contracting process has both a buyer that is flagged (``buyer_id``) and a tenderer that is flagged (``tenderer_id``), there will be 3 rows, not 1. For example:

   ============= ======== ===== ======== ===========
   ocid          subject  code  buyer_id tenderer_id
   ============= ======== ===== ======== ===========
   ocds-213czf-1 OCID     NF024          
   ocds-213czf-1 Buyer    NF038 1        
   ocds-213czf-1 Tenderer NF025          3
   ============= ======== ===== ======== ===========

indicator table
---------------

Purpose
  Lookup categories, titles and descriptions of `Cardinal indicator <https://cardinal.readthedocs.io/en/latest/cli/indicators/index.html#list>`__ codes.
Update frequency
  As needed, when new indicators are implemented.
Install
  Load the ``indicator.csv`` file, replacing the ``{{ path }}``:

  .. literalinclude:: ../../salt/kingfisher/collect/files/sql/indicator.sql
     :language: sql

  .. dropdown:: indicator.csv
     :icon: table

     .. csv-table::
        :file: ../../salt/kingfisher/collect/files/data/indicator.csv
        :header-rows: 1

codelist table
--------------

Purpose
  Lookup translations of English codes that occur in the OCDS data.
Update frequency
  As needed, when new codes need translations.
Install
  Load the ``codelist.csv`` file, replacing the ``{{ path }}``:

  .. literalinclude:: ../../salt/kingfisher/collect/files/sql/codelist.sql
     :language: sql

  .. dropdown:: codelist.csv
     :icon: table

     .. csv-table::
        :file: ../../salt/kingfisher/collect/files/data/codelist.csv
        :header-rows: 1

cpc table
---------

Purpose
  Lookup descriptions of `Central Product Classification (CPC) <https://unstats.un.org/unsd/classifications/Econ/CPC.cshtml>`__ codes.
Source
  `Ecuador <https://aplicaciones2.ecuadorencifras.gob.ec/SIN/metodologias/CPC%202.0.pdf>`__ (2012-06) publishes CPC Ver. 2 with different Spanish labels than `UNSD <https://unstats.un.org/unsd/classifications/Econ/CPC.cshtml>`__. (CPC 2.1 contains new codes, in English only). English labels from UNSD and Spanish labels from Ecuador were manually combined for 1, 2 and 3-digit codes.
Update frequency
  Every few years.
Install
  Load the ``cpc.csv`` file, replacing the ``{{ path }}``:

  .. literalinclude:: ../../salt/kingfisher/collect/files/sql/cpc.sql
     :language: sql

  .. dropdown:: cpc.csv
     :icon: table

     .. csv-table::
        :file: ../../salt/kingfisher/collect/files/data/cpc.csv
        :header-rows: 1

unspsc table
------------

Purpose
  Lookup descriptions of `United Nations Standard Products and Services Code (UNSPSC) <https://www.unspsc.org>`__ codes.
Source
  OCP has parts of UNPSC in `English <https://docs.google.com/spreadsheets/d/1_aVRybL5hF9o1uYKD5NcATQQGFyc9eGGcja3oaJo4EM/edit#gid=527001288>`__ and `Spanish <https://docs.google.com/spreadsheets/d/1r0qC1hPMw4XBBx7CUP1xnZeLD0CgOe_yAocLomOeVXQ/edit#gid=1593824065>`__. English and Spanish labels were manually combined for 2-digit codes.
Update frequency
  Every few years.
Install
  Load the ``unspsc.csv`` file, replacing the ``{{ path }}``:

  .. literalinclude:: ../../salt/kingfisher/collect/files/sql/unspsc.sql
     :language: sql

  .. dropdown:: unspsc.csv
     :icon: table

     .. csv-table::
        :file: ../../salt/kingfisher/collect/files/data/unspsc.csv
        :header-rows: 1

excluded_supplier table
-----------------------

Purpose
  Display the “Proportion of contracting processes for buyer with debarred suppliers” chart.
Source
  The Dominican Republic publishes `debarred suppliers <https://datosabiertos.dgcp.gob.do/opendata/tablas>`__ (*proveedores inhabilitados*) in CSV format.
Update frequency
  Daily.
Install
  Create the SQL table:

  .. literalinclude:: ../../salt/kingfisher/collect/files/sql/excluded_supplier.sql
     :language: sql

  Add the cron job:

  .. literalinclude:: ../../salt/cron/files/do_excluded_supplier.sh
     :language: bash

{% from 'lib.sls' import create_pg_database %}

{{ create_pg_database('covid19', 'covid19') }}

## Note this task, while having a title that suggests it is for any postgres server, contains settings that are specific for Kingfisher

postgresql-11:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main
    - dist: bionic-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
  pkg.installed:
    - name: postgresql-11
  service:
    - name: postgresql
    - running

/etc/postgresql/11/main/pg_hba.conf:
  file.managed:
    - source: salt://postgres/ocdskingfisher_pg_hba.conf
    - watch_in:
      - service: postgresql 

/etc/postgresql/11/main/conf.d/030_kingfisher-process1.conf:
  file.managed:
    - source: salt://postgres/ocdskingfisher_postgres.conf
    - watch_in:
      - service: postgresql 

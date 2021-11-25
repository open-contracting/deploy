{% set userdir = '/home/' + pillar.docker.user %}

{%
  for basename, source_hash in [
    ('001_base', '2b195c9983988080c5563ae0af4f722cfe51ece9882fe0e0ade5c324bd2eefab'),
    ('002_constraints', 'f298f0b8cb20d47f390b480d44d12c097e83b177dde56234dcbebc6ad3dcf229'),
  ]
%}
/opt/pelican-backend/{{ basename }}.sql:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/pelican-backend/main/pelican/migrations/{{ basename }}.sql
    - source_hash: {{ source_hash }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

run pelican migration {{ basename }}:
  cmd.run:
    - name: psql -c 'SET ROLE pelican_backend' -f /opt/pelican-backend/{{ basename }}.sql pelican_backend
    - runas: postgres
    - onchanges:
      - file: /opt/pelican-backend/{{ basename }}.sql
    - require:
      - postgres_database: pelican_backend
{% endfor %}

/opt/pelican-backend/exchange_rates.csv:
  file.managed:
    - source: salt://private/files/exchange_rates.csv
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

# After the migrations run, manually populate the exchange_rates table.
#
# psql -c 'SET ROLE pelican_backend' -c "\copy exchange_rates (id, valid_on, rates, created, modified) from '/opt/pelican-backend/exchange_rates.csv' delimiter ',' csv header;" pelican_backend

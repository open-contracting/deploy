{% set userdir = '/home/' + docker.user %}

{{ userdir }}/.pgpass:
  file.managed:
    - source: salt://postgres/files/pelican-backend.pgpass
    - template: jinja
    - user: {{ docker.user }}
    - group: {{ docker.user }}
    - mode: 400
    - require:
      - user: {{ docker.user }}_user_exists

{% for basename in ['001_base', '002_constraints'] %}
/opt/pelican-backend/{{ basename }}.sql:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/pelican-backend/main/migrations/{{ basename }}.sql
    - source_hash: 992e5487d2776280c0c47bc4aa7936c46672a0c4d01313a5953a9fb8ac3d306e
    - user: {{ docker.user }}
    - group: {{ docker.user }}
    - makedirs: True
    - require:
      - user: {{ docker.user }}_user_exists

run pelican migration {{ basename }}:
  cmd.run:
    - name: psql -f /opt/pelican-backend/{{ basename }}.sql pelican_backend
    - runas: {{ docker.user }}
    - onchanges:
      - file: /opt/pelican-backend/{{ basename }}.sql
    - require:
      - postgres_database: pelican_backend
      - file: {{ userdir }}/.pgpass
{% endfor %}

/opt/pelican-backend/exchange_rates.csv:
  file.managed:
    - source: salt://private/files/exchange_rates.csv
    - user: {{ docker.user }}
    - group: {{ docker.user }}
    - makedirs: True
    - require:
      - user: {{ docker.user }}_user_exists

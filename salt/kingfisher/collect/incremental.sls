{% from 'lib.sls' import create_user, set_cron_env %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user, authorized_keys=salt['pillar.get']('ssh:incremental', [])) }}

{{ userdir }}/data:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/logs:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/.pgpass:
  file.managed:
    - contents: |
        localhost:5432:kingfisher_collect:kingfisher_collect:{{ pillar.postgres.users.kingfisher_collect.password }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - user: {{ entry.user }}_user_exists

{{ set_cron_env(entry.user, 'MAILTO', 'sysadmin@open-contracting.org') }}

# Note that "%" has special significance in cron, so it must be escaped.
{% for crawl in entry.crawls %}
cd {{ directory }}; .ve/bin/scrapy crawl {{ crawl.spider }}{% if 'options' in crawl %} {{ crawl.options }}{% endif %} -a crawl_time={{ crawl.start_date }}T00:00:00 --logfile={{ userdir }}/logs/{{ crawl.spider }}-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }}
    - user: {{ entry.user }}
    {% if 'day' in crawl %}
    - daymonth: '{{ crawl.day }}'
    {% endif %}
    - hour: 0
    - minute: 15
    - require:
      - virtualenv: {{ directory }}/.ve
      - file: {{ userdir }}/data
      - file: {{ userdir }}/logs
{% endfor %}

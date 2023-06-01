{% from 'lib.sls' import create_user, set_cron_env %}
{% from 'kingfisher/collect/init.sls' import directory as scrapyd_directory %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

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
    - source: salt://postgres/files/kingfisher-collect.pgpass
    - template: jinja
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - user: {{ entry.user }}_user_exists

{%
  set crawls = [
    {
      'identifier': 'CHILE',
      'spider': 'chile_compra_api_records',
      'start_date': '2021-12-03',
      'day': 1,
      'options': '-a compile_releases=true',
    },
    {
      'identifier': 'ECUADOR',
      'spider': 'ecuador_sercop_bulk',
      'start_date': '2015-01-01',
    },
    {
      'identifier': 'MOLDOVA',
      'spider': 'moldova',
      'start_date': '2021-06-11',
    },
  ]
%}
#    {
#      'identifier': 'DOMINICAN_REPUBLIC',
#      'spider': 'dominican_republic_api',
#      'start_date': '2018-01-01',
#      'options': '-a compile_releases=true',
#    },

{{ set_cron_env(entry.user, "MAILTO", "sysadmin@open-contracting.org") }}
# This line can be removed after upgrading Python and Scrapy.
# - "CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography and will be removed in a future release."
# - https://github.com/open-contracting/kingfisher-collect/issues/998
{{ set_cron_env(entry.user, "PYTHONWARNINGS", "ignore:::OpenSSL._util,ignore:::scrapy.core.scraper") }}

# Note that "%" has special significance in cron, so it must be escaped.
{% for crawl in crawls %}
cd {{ directory }}; . .ve/bin/activate; scrapy crawl {{ crawl.spider }}{% if 'options' in crawl %} {{ crawl.options }}{% endif %} -a crawl_time={{ crawl.start_date }}T00:00:00 --logfile={{ userdir }}/logs/{{ crawl.spider }}-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/ocdskingfishercollect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }}
    - user: {{ entry.user }}
    {% if 'day' in crawl %}
    - daymonth: {{ crawl.day }}
    {% endif %}
    - hour: 0
    - minute: 15
    - require:
      - virtualenv: {{ directory }}/.ve
      - file: {{ userdir }}/data
      - file: {{ userdir }}/logs
{% endfor %}

{% from 'lib.sls' import create_user, set_cron_env, systemd, virtualenv %}

include:
  - python.virtualenv
  - python.extensions # twisted
  - python.psycopg2

{% set entry = pillar.kingfisher_collect %}
{% set user = entry.user %}
{% set group = entry.group|default(user) %}
{% set userdir = '/home/' + user %}
{% set directory = userdir + '/scrapyd' %}

{{ create_user(user) }}

# Allow data support managers to access, to read Scrapy's crawl logs.
allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ directory }}:
  file.directory:
    - names:
      - {{ directory }}/dbs
      - {{ directory }}/eggs
      - {{ directory }}/jobs
      - {{ directory }}/logs
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists

# Allow Docker apps (Kingfisher Process) to access.
{{ pillar.kingfisher_collect.env.FILES_STORE }}:
  file.directory:
    - user: {{ pillar.kingfisher_collect.user }}
    - group: {{ pillar.kingfisher_collect.group }}
    - makedirs: True
    - mode: 2775
    - require:
      - user: {{ pillar.kingfisher_collect.user }}_user_exists
      - user: {{ pillar.kingfisher_collect.group }}_user_exists

{{ directory }}/requirements.txt:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/kingfisher-collect/{{ pillar.kingfisher_collect.ref|default('main') }}/requirements.txt
    - source_hash: https://raw.githubusercontent.com/open-contracting/kingfisher-collect/{{ pillar.kingfisher_collect.ref|default('main') }}/requirements.txt.sha256
    - user: {{ user }}
    - group: {{ user }}
    - mode: 444
    - require:
      - file: {{ directory }}

{{ virtualenv(directory, user, {'file': directory}, {'file': directory + '/requirements.txt'}, 'scrapyd') }}

# https://scrapyd.readthedocs.io/en/stable/config.html
{{ userdir }}/.scrapyd.conf:
  file.managed:
    - source: salt://kingfisher/collect/files/scrapyd.ini
    - template: jinja
    - context: {{ dict(appdir=directory, **entry.get('context', {}))|yaml }}
    - watch_in:
      - service: scrapyd

/var/log/scrapyd:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require_in:
      - service: scrapyd

{{ systemd({'service': 'scrapyd', 'user': user, 'group': group, 'appdir': directory}) }}

{{ set_cron_env(user, 'MAILTO', 'sysadmin@open-contracting.org', 'kingfisher.collect') }}

{% if entry.get('summarystats') %}
find {{ userdir }}/scrapyd/logs/ -type f -name "*.log" -exec sh -c 'if [ ! -f {}.stats ]; then result=$(tac {} | head -n99 | grep -m1 -B99 statscollectors | tac); if [ ! -z "$result" ]; then echo "$result" > {}.stats; fi; fi' \;:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_LOG_STATS
    - user: {{ user }}
    - minute: 0
    - require:
      - file: {{ directory }}
{% endif %}

{% if entry.get('autoremove') %}
# Delete crawl logs older than 90 days.
find {{ userdir }}/scrapyd/logs/ -type f -ctime +90 -delete; find {{ userdir }}/scrapyd/logs/ -type d -empty -delete:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_DELETE_LOGS
    - user: {{ user }}
    - daymonth: 1
    - hour: 2
    - minute: 30
    - require:
      - file: {{ directory }}

# Delete crawl directories containing exclusively files older than 90 days.
for dir in $(find {{ pillar.kingfisher_collect.env.FILES_STORE }} -mindepth 2 -maxdepth 2 -type d); do if [ -z "$(find $dir -ctime -90)" ]; then rm -rf $dir; fi; done; find {{ pillar.kingfisher_collect.env.FILES_STORE }} -type d -empty -delete:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_DELETE_DATA
    - user: {{ user }}
    - daymonth: 1
    - hour: 2
    - minute: 45
    - require:
      - file: {{ pillar.kingfisher_collect.env.FILES_STORE }}
{% endif %}

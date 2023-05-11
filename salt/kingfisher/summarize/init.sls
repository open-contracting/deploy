{% from 'lib.sls' import set_cron_env %}

include:
  - kingfisher.process
  - python_apps

{% set entry = pillar.python_apps.kingfisher_summarize %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ directory }}/.env:
  file.managed:
    - source: salt://kingfisher/summarize/files/.env
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - git: {{ entry.git.url }}

{{ set_cron_env(entry.user, "MAILTO", "sysadmin@open-contracting.org") }}

# Delete schema whose selected collections no longer exist.
cd {{ directory }}; . .ve/bin/activate; python manage.py -q dev stale | xargs -I{} python manage.py --quiet remove {}:
  cron.present:
    - identifier: KINGFISHER_SUMMARIZE_ORPHAN_SCHEMA
    - user: {{ entry.user }}
    - daymonth: 1
    - hour: 3
    - minute: 45
    - require:
      - virtualenv: {{ directory }}/.ve

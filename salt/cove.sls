{% from 'lib.sls' import create_user %}

include:
  - apache.modules.remoteip
  # https://github.com/open-contracting/cove-ocds/pull/159
  - python.extensions  # backports-datetime-fromisoformat
  - python_apps

{% set entry = pillar.python_apps.cove %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

cd {{ directory }}; . .ve/bin/activate; SECRET_KEY="{{ entry.django.env.SECRET_KEY|replace('%', '\%') }}" python manage.py expire_files --settings {{ entry.django.app }}.settings:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: {{ entry.user }}
    - hour: 0
    - minute: random
    - require:
      - virtualenv: {{ directory }}/.ve

set MAILTO environment variable in {{ entry.user }} crontab:
  cron.env_present:
    - name: MAILTO
    - value: sysadmin@open-contracting.org
    - user: {{ entry.user }}
    - require:
      - user: {{ user }}_user_exists

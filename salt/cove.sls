{% from 'lib.sls' import create_user %}

include:
  - apache.modules.remoteip
  - python_apps

{% set entry = pillar.python_apps.cove %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

cove-prerequisites: # for packages with C extensions
  pkg.installed:
    - pkgs:
      - python3-dev
      - build-essential
    - require_in:
      - cmd: {{ directory }}-requirements

cd {{ directory }}; . .ve/bin/activate; SECRET_KEY="{{ entry.django.env.SECRET_KEY|replace('%', '\%') }}" python manage.py expire_files --settings {{ entry.django.app }}.settings:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: {{ entry.user }}
    - minute: random
    - hour: 0

set MAILTO environment variable in {{ entry.user }} crontab:
  cron.env_present:
    - name: MAILTO
    - value: sysadmin@open-contracting.org
    - user: {{ entry.user }}

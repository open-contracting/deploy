{% from 'lib.sls' import create_user, set_cron_env %}

include:
  # https://github.com/open-contracting/cove-ocds/pull/159
  - python.extensions  # backports-datetime-fromisoformat
  - python_apps

{% set entry = pillar.python_apps.cove %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

# Allow Apache to access. See django.conf.include.
allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ entry.user }}_user_exists

{{ set_cron_env(entry.user, 'MAILTO', 'sysadmin@open-contracting.org') }}

cd {{ directory }}; SECRET_KEY="{{ entry.django.env.SECRET_KEY|replace('%', '\%') }}" .ve/bin/python manage.py expire_files --settings {{ entry.django.app }}.settings:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: {{ entry.user }}
    - hour: 0
    - minute: random
    - require:
      - virtualenv: {{ directory }}/.ve

# By default this clears down /tmp data older than 7 days.
clean up tmp data when python errors:
  pkg.installed:
    - name: tmpreaper

/etc/tmpreaper.conf:
  file.replace:
    - name: /etc/tmpreaper.conf
    - pattern: "^SHOWWARNING=true"
    - repl: "#SHOWWARNING=true"
    - backup: False

useful commands for CoVE analysis:
  pkg.installed:
    - pkgs:
      - jq
      - ripgrep

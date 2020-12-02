{% from 'lib.sls' import createuser %}

{% set user = 'ocdskfs' %}
{% set userdir = '/home/' + user %}

{% set archive_giturl = 'https://github.com/open-contracting/kingfisher-archive.git' %}
{% set archive_dir = userdir + '/ocdskingfisherarchive' %}
{% set scrapyd_dir = userdir + '/scrapyd' %}

{{ archive_giturl }}{{ archive_dir }}:
  git.latest:
    - name: {{ archive_giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ archive_dir }}
    - require:
      - pkg: git
      - user: {{ user }}_user_exists

{{ archive_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ archive_giturl }}{{ archive_dir }}

{{ archive_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ archive_dir }}
    - require:
      - virtualenv: {{ archive_dir }}/.ve/

{{ archive_dir }}/.env:
  file.managed:
    - source: salt://kingfisher-archive/.env
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400
    - makedirs: True
    - context:
        userdir: {{ userdir }}
        scrapyd_dir: {{ scrapyd_dir }}
    - require:
      - git: {{ archive_giturl }}{{ archive_dir }}

{{ userdir }}/.config/ocdskingfisher-archive/logging.json:
  file.managed:
    - source: salt://kingfisher-archive/logging.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - context:
        userdir: {{ userdir }}

/etc/rsyslog.d/92-kingfisher-archive.conf:
  file.managed:
    - source: salt://kingfisher-archive/rsyslog.conf

/etc/logrotate.d/archive:
  file.managed:
    - source: salt://kingfisher-archive/logrotate.conf
    - makedirs: True

#cd {{ archive_dir }}; source .ve/bin/activate; python manage.py archive:
#  cron.present:
#    - identifier: OCDS_KINGFISHER_ARCHIVE_RUN
#    - user: {{ user }}
#    - minute: 0
#    - hour: 1
#    - dayweek: 6

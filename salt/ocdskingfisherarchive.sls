{% from 'lib.sls' import createuser %}

{% set user = 'ocdskfs' %}
{% set userdir = '/home/' + user %}

{% set giturl = 'https://github.com/open-contracting/kingfisher-archive.git' %}
{% set ocdskingfisherdir = userdir + '/ocdskingfisherarchive' %}
{% set scrapyddir = userdir + '/scrapyd' %}

{{ giturl }}{{ ocdskingfisherdir }}:
  git.latest:
    - name: {{ giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ ocdskingfisherdir }}
    - require:
      - pkg: git
      - user: {{ user }}_user_exists

{{ ocdskingfisherdir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ giturl }}{{ ocdskingfisherdir }}

archive_pip_install_requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - virtualenv: {{ ocdskingfisherdir }}/.ve/

{{ ocdskingfisherdir }}/.env:
  file.managed:
    - source: salt://ocdskingfisherarchive/.env
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400
    - makedirs: True
    - context:
        userdir: {{ userdir }}
        scrapyddir: {{ scrapyddir }}
    - require:
      - git: {{ giturl }}{{ ocdskingfisherdir }}

{{ userdir }}/.config/ocdskingfisher-archive/logging.json:
  file.managed:
    - source: salt://ocdskingfisherarchive/logging.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - context:
        userdir: {{ userdir }}

/etc/rsyslog.d/92-kingfisher-archive.conf:
  file.managed:
    - source: salt://ocdskingfisherarchive/rsyslog.conf

/etc/logrotate.d/archive:
  file.managed:
    - source: salt://ocdskingfisherarchive/logrotate
    - makedirs: True

#cd {{ ocdskingfisherdir }}; source .ve/bin/activate; python manage.py archive:
#  cron.present:
#    - identifier: OCDS_KINGFISHER_ARCHIVE_RUN
#    - user: {{ user }}
#    - minute: 0
#    - hour: 1
#    - dayweek: 6

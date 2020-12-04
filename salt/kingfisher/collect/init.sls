{% from 'lib.sls' import apache, createuser %}

include:
  - apache.public
  - apache.modules.proxy_http

kingfisher-collect-prerequisites:
  pkg.installed:
    - pkgs:
      - supervisor

{% set user = 'ocdskfs' %}
{% set userdir = '/home/' + user %}
{{ createuser(user, authorized_keys=pillar.ssh.kingfisher) }}

{% set scrapyd_dir = userdir + '/scrapyd' %}

{{ scrapyd_dir }}:
  file.directory:
    - makedirs: True
    - user: {{ user }}
    - group: {{ user }}

{{ scrapyd_dir }}/requirements.txt-expire:
  file.not_cached:
    - name: https://raw.githubusercontent.com/open-contracting/kingfisher-collect/master/requirements.txt

{{ scrapyd_dir }}/requirements.txt:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/kingfisher-collect/master/requirements.txt
    - skip_verify: True
    - user: {{ user }}
    - group: {{ user }}
    - mode: 444
    - require:
      - file: {{ scrapyd_dir }}

{{ scrapyd_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - cwd: {{ scrapyd_dir }}
    - pip_pkgs:
        - pip-tools
    - require:
      - file: {{ scrapyd_dir }}

{{ scrapyd_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ scrapyd_dir }}
    - require:
      - virtualenv: {{ scrapyd_dir }}/.ve/
    - onchanges:
      - file: {{ scrapyd_dir }}/requirements.txt

{{ scrapyd_dir }}/dbs:
  file.directory:
    - makedirs: True
    - user: {{ user }}
    - group: {{ user }}

{{ scrapyd_dir }}/eggs:
  file.directory:
    - makedirs: True
    - user: {{ user }}
    - group: {{ user }}

{{ scrapyd_dir }}/logs:
  file.directory:
    - makedirs: True
    - user: {{ user }}
    - group: {{ user }}

{{ userdir }}/.scrapyd.conf:
  file.managed:
    - source: salt://kingfisher/collect/files/scrapyd.ini
    - template: jinja
    - context:
        scrapyd_dir: {{ scrapyd_dir }}

/etc/supervisor/conf.d/scrapyd.conf:
  file.managed:
    - source: salt://kingfisher/collect/files/supervisor.conf
    - template: jinja
    - context:
        scrapyd_dir: {{ scrapyd_dir }}
    - watch_in:
      - service: supervisor

supervisor:
  pkg.installed:
    - name: supervisor
  service.running:
    - name: supervisor
    - enable: True
    - reload: True

{{ apache('kingfisher-collect',
    name='ocdskingfisherscrape',
    servername='collect.kingfisher.open-contracting.org',
    extracontext='user: ' + user) }}

find {{ userdir }}/scrapyd/logs/ -type f -name "*.log" -exec sh -c 'if [ ! -f {}.stats ]; then result=$(tac {} | head -n99 | grep -m1 -B99 statscollectors | tac); if [ ! -z "$result" ]; then echo "$result" > {}.stats; fi; fi' \;:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_LOG_STATS
    - user: {{ user }}
    - minute: 0

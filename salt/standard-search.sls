{% from 'lib.sls' import createuser, apache, uwsgi, django %}

{% set user = 'standard-search' %}
{{ createuser(user) }}

include:
  - apache
  - uwsgi

standard-search-deps:
    apache_module.enabled:
      - name: proxy
      - watch_in:
        - service: apache2
    pkg.installed:
      - pkgs:
        - libapache2-mod-proxy-uwsgi
        - python-pip
        - python-virtualenv
        - uwsgi-plugin-python3
        - apt-transport-https
      - watch_in:
        - service: apache2
        - service: uwsgi

standard-search-uwsgi:
    apache_module.enabled:
      - name: proxy_uwsgi
      - watch_in:
        - service: apache2
      - require:
        - pkg: standard-search-deps

elasticsearch:
  cmd.run:
    - name: wget -nv -O - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -

  pkgrepo.managed:
    - humanname: Elasticsearch
    - name: deb https://artifacts.elastic.co/packages/6.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list

  pkg.installed:
    - pkgs:
      - elasticsearch
      - openjdk-8-jre-headless

  service.running:
    - name: elasticsearch
    - enable: True
    - watch:
      - file: /etc/elasticsearch/*

  # Ensure elasticsearch only listens on localhost, doesn't multicast
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        network.host: 127.0.0.1

/etc/default/elasticsearch:
  file.managed:
    - source: salt://etc-default/elasticsearch-standard-search
    - template: jinja

/etc/elasticsearch/jvm.options:
  file.managed:
    - source: salt://standard-search/jvm.options
    - template: jinja

{% set name = 'ocds-search' %}
{% set djangodir = '/home/' + user + '/' + name + '/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
bare_name: {{ name }}
{% endset %}

{{ apache(user + '.conf',
    name=name + '.conf',
    servername='standard-search.open-contracting.org',
    serveraliases=['www.live.standard-search.opencontracting.uk0.bigv.io'],
    https='yes',
    extracontext=extracontext) }}

{{ uwsgi(user + '.ini',
    name=name + '.ini',
    extracontext=extracontext) }}

{{ django(name,
    user,
    'https://github.com/OpenDataServices/standard-search.git',
    'master',
    djangodir,
    'standard-search-uwsgi',
    compilemessages=False) }}

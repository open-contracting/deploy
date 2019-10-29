# Toucan used to be named ocdskit-web. We have not yet changed occurrences of r'ocskit.web' where a simple rename would
# cause a doubling of users, directories, config files, etc.

{% from 'lib.sls' import createuser, private_keys, apache, uwsgi %}

include:
  - core
  - apache
  - apache-proxy
  - uwsgi
  - letsencrypt

{% set user = 'ocdskit-web' %}
{{ createuser(user) }}

toucan-deps:
    apache_module.enabled:
      - name: proxy proxy_uwsgi
      - watch_in:
        - service: apache2
    pkg.installed:
      - pkgs:
        - libapache2-mod-proxy-uwsgi
        - python3-pip
        - python-virtualenv
        - uwsgi-plugin-python3
      - watch_in:
        - service: apache2
        - service: uwsgi

{% set giturl = 'https://github.com/open-contracting/toucan.git' %}
{% set userdir = '/home/' + user %}
{% set ocdskitwebdir = userdir + '/ocdskit-web/' %}

{% macro toucan(name, branch, giturl, user, servername, https='') %}

{% set djangodir='/home/'+user+'/'+name+'/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
branch: {{ branch }}
bare_name: {{ name }}
{% endset %}

{{ apache(user+'.conf',
    name=name+'.conf',
    extracontext=extracontext,
    servername=servername,
    https=https) }}

{{ uwsgi(user+'.ini',
    name=name+'.ini',
    extracontext=extracontext) }}

{{ giturl }}{{ djangodir }}:
  git.latest:
    - name: {{ giturl }}
    - rev: {{ branch }}
    - target: {{ djangodir }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git
    - watch_in:
      - service: uwsgi

# Install the latest version of pip first
# This is necessary to download linux wheels, which avoids building C code
{{ djangodir }}.ve/-pip:
  virtualenv.managed:
    - name: {{ djangodir }}.ve/
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs: pip==8.1.2
    - require:
      - pkg: toucan-deps
      - git: {{ giturl }}{{ djangodir }}

# Then install the rest of our requirements
{{ djangodir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - requirements: {{ djangodir }}requirements.txt
    - require:
      - virtualenv: {{ djangodir }}.ve/-pip
      - file: set_lc_all # required to avoid unicode errors for the "schema" library
    - watch_in:
      - service: apache2

migrate-{{name}}:
  cmd.run:
    - name: . .ve/bin/activate; python manage.py migrate --noinput
    - user: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

#compilemessages-{{name}}:
#  cmd.run:
#    - name: . .ve/bin/activate; python manage.py compilemessages
#    - user: {{ user }}
#    - cwd: {{ djangodir }}
#    - require:
#      - virtualenv: {{ djangodir }}.ve/
#    - onchanges:
#      - git: {{ giturl }}{{ djangodir }}

collectstatic-{{name}}:
  cmd.run:
    - name: . .ve/bin/activate; python manage.py collectstatic --noinput
    - user: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

{{ djangodir }}static/:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - recurse:
      - mode
    - require:
      - cmd: collectstatic-{{name}}
    - user: {{ user }}
    - group: {{ user }}

{{ djangodir }}:
  file.directory:
    - dir_mode: 755
    - require:
      - cmd: collectstatic-{{name}}
    - user: {{ user }}
    - group: {{ user }}

{% endmacro %}

{{ toucan(
    name='ocdskit-web',
    branch=pillar.toucan.default_branch,
    giturl=giturl,
    user=user,
    servername='toucan.open-contracting.org',
    https='force'
    ) }}

# Set up an redirect from an old server name
{{ apache('ocdskit-web-redirects.conf',
    name='ocdskit-web-redirects.conf') }}


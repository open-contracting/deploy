# Toucan used to be named ocdskit-web. We have not yet changed occurrences of r'ocskit.?web' where a simple rename
# would cause a doubling of users, directories, config files, etc.

{% from 'lib.sls' import createuser, apache, uwsgi, django %}

include:
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
{% set name = 'ocdskit-web' %}
{% set branch = pillar.toucan.default_branch %}
{% set djangodir = '/home/' + user + '/' + name + '/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
branch: {{ branch }}
bare_name: {{ name }}
{% endset %}

{{ apache(user + '.conf',
    name=name + '.conf',
    extracontext=extracontext,
    servername='toucan.open-contracting.org',
    https='force') }}

{{ uwsgi(user + '.ini',
    name=name + '.ini',
    extracontext=extracontext) }}

{{ django(name, user, giturl, branch, djangodir, 'pkg: toucan-deps') }}

# Set up an redirect from an old server name
{{ apache('ocdskit-web-redirects.conf',
    name='ocdskit-web-redirects.conf') }}


# Toucan used to be named ocdskit-web. We have not yet changed occurrences of r'ocskit.?web' where a simple rename
# would cause a doubling of users, directories, config files, etc.

{% from 'lib.sls' import createuser, apache, uwsgi, django %}

{% set user = 'ocdskit-web' %}
{{ createuser(user) }}

include:
  - apache-proxy
  - uwsgi

{{ user }}-deps:
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

{% set name = 'ocdskit-web' %}
{% set djangodir = '/home/' + user + '/' + name + '/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
{% endset %}

{{ apache(user + '.conf',
    name=name + '.conf',
    servername='toucan.open-contracting.org',
    https='force',
    extracontext=extracontext) }}

{{ uwsgi(user + '.ini',
    name=name + '.ini',
    extracontext=extracontext) }}

{{ django(name,
    user,
    'https://github.com/open-contracting/toucan.git',
    'master',
    djangodir) }}

# Set up a redirect from an old server name.
{{ apache('ocdskit-web-redirects.conf') }}

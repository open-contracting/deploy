{% from 'lib.sls' import createuser, apache %}

include:
  - prometheus-client-common

# NOTE: We probably should require some kind of nginx package here.
# The one server this is currently used on has this from redash, so we'll do that later.

# Note user variable is set in other prometheus-client-*.sls files too!
{% set user = 'prometheus-client' %}

########### Nginx Reverse Proxy with password for security

/home/{{ user }}/htpasswd:
  file.managed:
    - contents_pillar: prometheus:client_password_as_nginx_file

/etc/nginx/sites-available/prometheus-client:
  file.managed:
    - source: salt://nginx/prometheus-client
    - template: jinja
    - context:
        user: {{ user }}

# Create a symlink from sites-enabled to enable the config
/etc/nginx/sites-enabled/prometheus-client:
  file.symlink:
    - target: /etc/nginx/sites-available/prometheus-client
    - require:
      - file: /etc/nginx/sites-available/prometheus-client
    - makedirs: True

restart-nginx-for-prometheus:
  cmd.run:
    - name: /etc/init.d/nginx restart
    - require:
      - file: /home/{{ user }}/htpasswd
      - file: /etc/nginx/sites-enabled/prometheus-client

{% from 'lib.sls' import apache, set_firewall %}

{{ set_firewall("PUBLIC_HTTP") }}
{{ set_firewall("PUBLIC_HTTPS") }}

apache2:
  pkg.installed:
    - pkgs:
      - apache2
      # http://docs.saltstack.cn/ref/states/all/salt.states.htpasswd.html
      - apache2-utils
  service.running:
    - name: apache2
    - enable: True
    - reload: True

letsencrypt:
  pkg.installed:
    - name: letsencrypt

/etc/apache2/mods-enabled/ssl.load:
  file.symlink:
    - target: /etc/apache2/mods-available/ssl.load
    - makedirs: True
    - watch_in:
      - service: apache2

/var/www/html/.well-known/acme-challenge:
  file.directory:
    - user: www-data
    - group: www-data
    - makedirs: True

# This file is not served unless explicitly aliased from an Apache configuration file.
/var/www/html/robots.txt:
  file.managed:
    - source: salt://apache/robots_dev.txt

cron-letsencrypt-renew:
  cron.present:
    - identifier: letsencrypt-renew
    - name: letsencrypt renew --no-self-upgrade >/dev/null 2>&1
    - user: root
    - minute: random
    - hour: 7
  require:
    - pkg: letsencrypt

# Ensure 000-default conf exists, so it's obvious when we've typo'd something
{{ apache('000-default') }}

# See also the {{ servername }}_acquire_certs ID in lib.sls

letsencrypt:
  pkg.installed

/var/www/html/.well-known/acme-challenge:
  file.directory:
    - user: www-data
    - group: www-data
    - makedirs: True

/etc/apache2/mods-enabled/ssl.load:
  file.symlink:
    - target: /etc/apache2/mods-available/ssl.load
    - makedirs: True
    - watch_in:
      - service: apache2

cron-letsencrypt-renew:
  cron.present:
    - identifier: letsencrypt-renew
    - name: letsencrypt renew --no-self-upgrade >/dev/null 2>&1
    - user: root
    - minute: random
    - hour: 7
  require:
    - pkg: letsencrypt

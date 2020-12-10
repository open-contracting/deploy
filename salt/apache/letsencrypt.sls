{% from 'lib.sls' import apache_conf %}

include:
  - apache.modules.ssl
  - core.snapd

/usr/local/share/ocp-letsencrypt/.well-known/acme-challenge:
  file.directory:
    - user: www-data
    - group: www-data
    - makedirs: True

# Enables .well-known authentication for LE SSL certs
{{ apache_conf("letsencrypt") }}

# Set up post renew hook to reload Apache for new certs
/etc/letsencrypt/renewal-hooks/deploy/letsencrypt_deploy_hook_apache.sh:
  file.managed:
    - source: salt://apache/files/scripts/letsencrypt_deploy_hook_apache.sh

# Waiting for this GH issue to be closed https://github.com/saltstack/salt/issues/58132
#certbot:
#  snap.installed
certbot:
  cmd.run:
    - name: snap install --classic certbot
    - creates: /snap/bin/certbot
  require:
    - sls: snapd

cron-letsencrypt-renew:
  cron.present:
    - identifier: letsencrypt-renew
    - name: certbot renew -q
    - user: root
    - minute: random
    - hour: 7
  require:
    - sls: certbot

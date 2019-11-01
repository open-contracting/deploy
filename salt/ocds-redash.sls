/etc/nginx/redash-htpasswd:
  file.managed:
    - contents_pillar: ocds-redash:htpasswd:contents

/etc/nginx/sites-available/redash:
  file.managed:
    - source: salt://nginx/redash

restart-nginx:
  cmd.run:
    - name: /etc/init.d/nginx restart
    - require:
      - file: /etc/nginx/redash-htpasswd
      - file: /etc/nginx/sites-available/redash

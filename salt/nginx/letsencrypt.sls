include:
  - nginx

certbot:
  pkg.installed:
    - pkgs:
      - certbot
      - python3-certbot-nginx

/etc/letsencrypt/cli.ini:
  file.append:
    - text: |
        email = sysadmin@open-contracting.org
        agree-tos = true
    - require:
      - pkg: certbot

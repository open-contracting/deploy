include:
  - ocds-docs-common

https://github.com/open-contracting/standard-legacy-staticsites.git:
  git.latest:
    - rev: master
    - target: /home/ocds-docs/web/legacy/
    - user: ocds-docs
    - force_fetch: True
    - force_reset: True

# Create the file in the virtual host's document root.
/home/ocds-docs/web/robots.txt:
  file.managed:
    - source: salt://ocds-docs/robots_live.txt
    - user: ocds-docs

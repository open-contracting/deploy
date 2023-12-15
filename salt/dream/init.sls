useful commands for RBC Group:
  pkg.installed:
    - pkgs:
      - mc
      - telnet

/usr/share/nginx/html:
  git.latest:
    - name: https://github.com/open-contracting/bi.dream.gov.ua
    - user: root
    - force_fetch: True
    - force_reset: True
    - branch: build
    - rev: build
    - target: /usr/share/nginx/html
    - require:
      - pkg: git

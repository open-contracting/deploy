include:
  - python

python c extensions:
  pkg.installed:
    - pkgs:
      - python{{ salt['pillar.get']('python:version', 3) }}-dev
      - build-essential
      - libffi-dev
      - libxml2-dev
      - libxslt1-dev

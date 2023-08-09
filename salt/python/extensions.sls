include:
  - python

python c extensions:
  pkg.installed:
    - pkgs:
      - python{{ salt['pillar.get']('python:version', 3) }}-dev
      - build-essential
      - libffi-dev

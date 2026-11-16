{% if salt['pillar.get']('python:version') %}
python:
  pkgrepo.managed:
    - ppa: deadsnakes/ppa
  pkg.installed:
    - pkgs:
      - python{{ pillar.python.version }}
    - require:
      - pkgrepo: python
{% endif %}

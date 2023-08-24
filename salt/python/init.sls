{% if salt['pillar.get']('python:version') %}
python:
  pkgrepo.managed:
    - ppa: deadsnakes/ppa
  pkg.installed:
    - pkgs:
      - python{{ pillar.python.version }}
      # Avoid "ModuleNotFoundError: No module named 'distutils.command'".
      - python{{ pillar.python.version }}-distutils
    - require:
      - pkgrepo: python
{% endif %}

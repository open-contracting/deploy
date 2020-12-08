supervisor:
  pkg.installed:
    - name: supervisor
  service.running:
    - name: supervisor
    - enable: True
    - reload: True
    - require:
      - pkg: supervisor

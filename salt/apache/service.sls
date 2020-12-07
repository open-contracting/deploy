apache2:
  pkg.installed:
    - name: apache2
  service.running:
    - name: apache2
    - enable: True
    - reload: True
    - require:
      - pkg: apache2

uwsgi:
  pkg.installed:
    - name: uwsgi
  service.running:
    - name: uwsgi
    - enable: True
    - reload: True

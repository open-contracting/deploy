grafana dependencies:
  pkg.installed:
    - pkgs:
      - software-properties-common

grafana:
  pkgrepo.managed:
    - humanname: Grafana Official Repository
    - name: deb [arch={{ grains.osarch }} signed-by=/usr/share/keyrings/grafana-keyring.gpg] https://apt.grafana.com stable main
    - aptkey: False
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/grafana.list
    - key_url: https://apt.grafana.com/gpg.key
  pkg.installed:
    - name: grafana
    - require:
      - pkgrepo: grafana
  service.running:
    - name: grafana-server.service
    - enable: True
    - require:
      - pkg: grafana

/etc/grafana/grafana.ini:
  ini.options_present:
    - name: /etc/grafana/grafana.ini
    - sections:
        server:
          http_addr: '127.0.0.1'
        users:
          allow_sign_up: true
    - watch_in:
      - service: grafana

/etc/grafana/provisioning/datasources/prometheus.yaml:
  file.managed:
    - source: salt://grafana/files/datasource.yaml
    - template: jinja
    - user: root
    - group: grafana
    - require:
      - pkg: grafana
    - watch_in:
      - service: grafana

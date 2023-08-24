include:
  - apache

passenger:
  pkgrepo.managed:
    - humanname: Phusion Passenger Official Repository
    - name: deb https://oss-binaries.phusionpassenger.com/apt/passenger {{ grains.oscodename }} main
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/passenger.list
    - keyid: 561F9B9CAC40B2F7
    - keyserver: keyserver.ubuntu.com
  pkg.installed:
    - name: libapache2-mod-passenger
    - require:
      - pkgrepo: passenger
  apache_module.enabled:
    - require:
      - pkg: passenger
    - watch_in:
      - service: apache2

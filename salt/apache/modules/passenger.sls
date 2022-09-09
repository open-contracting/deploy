include:
  - apache

# https://www.phusionpassenger.com/library/install/apache/install/oss/bionic/
passenger dependencies:
  pkg.installed:
    - pkgs:
      - dirmngr
      - gnupg
      - python3-gnupg
      - apt-transport-https
      - ca-certificates

passenger:
  pkgrepo.managed:
    - humanname: Phusion Passenger Official Repository
    - name: deb https://oss-binaries.phusionpassenger.com/apt/passenger {{ grains.oscodename }} main
    - dist: focal
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

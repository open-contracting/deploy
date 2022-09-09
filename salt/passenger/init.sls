{% from 'lib.sls' import apache, create_user %}

include:
  - apache

Passenger apt repo dependencies:
  pkg.installed:
    - pkgs:
      - gnupg
      - python3-gnupg
      - dirmngr
      - apt-transport-https
      - ca-certificates

# Configure official repository and install Apache module
passenger:
  pkgrepo.managed:
    - name: deb https://oss-binaries.phusionpassenger.com/apt/passenger {{ grains.oscodename }} main
    - dist: focal
    - file: /etc/apt/sources.list.d/passenger.list
    - keyid: 561F9B9CAC40B2F7
    - keyserver: keyserver.ubuntu.com
    - refresh_db: true
  pkg.installed:
    - name: libapache2-mod-passenger
    - require:
      - pkgrepo: passenger
  apache_module.enabled:
    - require:
      - pkg: passenger
    - watch_in:
      - service: apache2

# Install rvm enabling newer Ruby versions
rvm:
  group.present: []
  user.present:
    - gid: rvm
    - home: /home/rvm
    - require:
      - group: rvm
  pkgrepo.managed:
    - ppa: rael-gc/rvm
  pkg.installed:
    - name: rvm
    - require:
      - pkgrepo: rvm
      - user: rvm

# There is a bug with the salt rvm implementation breaking support for the apt managed package.
rvm salt integration:
  file.symlink:
    - name: /usr/local/rvm/bin/rvm
    - target: /usr/share/rvm/bin/rvm
    - makedirs: True

ruby-{{ pillar.ruby_version }}:
  rvm.installed:
    - default: True
    - require:
      - pkg: rvm

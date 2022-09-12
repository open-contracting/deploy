{% from 'lib.sls' import create_user %}

rvm:
  pkgrepo.managed:
    - ppa: rael-gc/rvm
  pkg.installed:
    - name: rvm
    - require:
      - pkgrepo: rvm

# A Salt bug breaks support for the apt-managed package.
rvm-symlink:
  file.symlink:
    - name: /usr/local/rvm/bin/rvm
    - target: /usr/share/rvm/bin/rvm
    - makedirs: True
    - require:
      - pkg: rvm

ruby-{{ pillar.rvm.default_version }}:
  rvm.installed:
    - default: True
    - require:
      - file: rvm-symlink

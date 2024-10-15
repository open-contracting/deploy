# Install and configure RKHunter.

{% set rkhunter_version = '1.4.6' %}

rkhunter requirements:
  pkg.installed:
    - pkgs:
      - binutils
      - file
      - lsof
      - wget

rkhunter_install:
  archive.extracted:
    - name: /tmp
    - source: https://rkhmirror.dogsbody.com/pkgs/rkhunter-{{ rkhunter_version }}.tar.gz
    # curl -sS https://rkhmirror.dogsbody.com/pkgs/rkhunter-1.4.6.tar.gz | shasum -a 256
    - source_hash: f750aa3e22f839b637a073647510d7aa3adf7496e21f3c875b7a368c71d37487
    # Only download and install rkhunter if missing (unless hash changed).
    - unless: test -f /usr/local/bin/rkhunter
  cmd.run:
    - name: ./installer.sh --layout default --install
    - cwd: /tmp/rkhunter-{{ rkhunter_version }}
    - onchanges:
      - archive: rkhunter_install

/var/lib/rkhunter/db/mirrors.dat:
  file.replace:
    - pattern: |
        mirror=http://rkhunter.sourceforge.net
        remote=http://rkhunter.sourceforge.net
    - repl: "local=https://rkhmirror.dogsbody.com/data/1.4/"
    - append_if_not_found: True
    - backup: False
    - require:
      - archive: rkhunter_install

rkhunter_update:
  cmd.run:
    - name: /usr/local/bin/rkhunter --update
    # Returns 2 if something is updated.
    - success_retcodes: [0, 2]
    - onchanges:
      - archive: rkhunter_install

rkhunter_propupd:
  cmd.run:
    - name: /usr/local/bin/rkhunter --propupd
    - onchanges:
      - archive: rkhunter_install

rkhunter_cleanup:
  file.absent:
    - name: /tmp/rkhunter-{{ rkhunter_version }}

/etc/cron.daily/rkhunter-check:
  file.managed:
    - source: salt://maintenance/rkhunter/files/rkhunter-check.sh
    - mode: 755

# Configure rkhunter
/etc/rkhunter.conf.local:
  file.managed:
    - source: salt://maintenance/rkhunter/files/rkhunter.conf.local
    - template: jinja

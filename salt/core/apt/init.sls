# Disable operating system release notifications.
/etc/update-manager/release-upgrades:
  file.keyvalue:
    - key: Prompt
    - value: never

/etc/apt/apt.conf.d/99-connection-timeouts:
  file.managed:
    - source: salt://core/apt/files/99-connection-timeouts

needrestart:
  pkg.removed:
    - name: needrestart

# https://www.phusionpassenger.com/library/install/apache/install/oss/bionic/
# gnupg depends on dirmngr. gnupg2 is a dummy package for gnupg.
secure ppa:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - gnupg

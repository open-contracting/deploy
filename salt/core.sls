# Defines a base configuration that we want installed on all of our servers.

core dependencies:
  pkg.installed:
    - pkgs:
      - git # nearly universal dependency
      - python-apt # required for salt to interact with apt

useful commands:
  pkg.installed:
    - pkgs:
      - htop
      - man-db
      - psmisc # provides killall
      - tmux
      - vim

## Security

fail2ban:
  pkg.installed:
    - pkgs:
      - fail2ban
      - mailutils

f2b-startup:
  service.running:
    - name: fail2ban
    - enable: True
    - reload: True
  require:
    - pkg: fail2ban

# Setup email alerts when bans are triggered - enabled only if the jail has a configured action.
/etc/fail2ban/action.d/mail-whois.local:
  file.managed:
    - source: salt://fail2ban/action.d/mail-whois.local

# Disable password login (use keys instead).
/etc/ssh/sshd_config:
  file.replace:
    - pattern: PasswordAuthentication yes
    - repl: PasswordAuthentication no

ssh:
  service.running:
    - name: ssh
    - enable: True
    - reload: True
    - watch: # reload if we change the config
      - file: /etc/ssh/sshd_config

root_authorized_keys_add:
  ssh_auth.present:
   - user: root
   - source: salt://private/authorized_keys/root_to_add
root_authorized_keys_remove:
  ssh_auth.absent:
   - user: root
   - source: salt://private/authorized_keys/root_to_remove

# Don't need RPC portmapper.
purge rpcbind:
  pkg.purged:
    - name: rpcbind

unattended-upgrades:
  pkg.installed:
    - pkgs:
      - unattended-upgrades # this perform unattended upgrades
      - update-notifier-common # this checks whether a restart is required

/etc/apt/apt.conf.d/50unattended-upgrades:
  file.managed:
    - source: salt://apt/50unattended-upgrades
    - template: jinja

/etc/apt/apt.conf.d/10periodic:
  file.managed:
    - source: salt://apt/10periodic

## Swap

create_swapfile:
  cmd.run:
    - name: dd if=/dev/zero of=/swapfile bs=10M count=100; chmod 600 /swapfile; mkswap /swapfile
    - creates: /swapfile

/swapfile:
  mount.swap:
    - require:
      - cmd: create_swapfile

## Miscellaneous

MAILTO_root:
  cron.env_present:
    - name: MAILTO
    - value: sysadmin@open-contracting.org,code@opendataservices.coop
    - user: root

set_lc_all:
  file.append:
    - text: 'LC_ALL="en_GB.UTF-8"'
    - name: /etc/default/locale

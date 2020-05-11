# Defines a base configuration that we want installed on all of our servers.

# git needs to be installed under its own ID to be referenced as a requisite.
# See https://github.com/saltstack/salt/issues/3683
git:
  pkg.installed:
    - name: git # nearly universal dependency

python-apt:
  pkg.installed:
    - name: python-apt # required for salt to interact with apt

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

# Disable password login (use keys instead).
/etc/ssh/sshd_config:
  file.replace:
    - pattern: "PasswordAuthentication yes|#PasswordAuthentication no"
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

## Locale

add_system_locale_en_gb_utf8:
  # This line may be in the file but commented out.
  # However we use file.append here instead of file.replace because we can't guarantee each Linux Distro build will comment out the lines in the same way.
  file.append:
    - name:  /etc/locale.gen
    - text: "en_GB.UTF-8 UTF-8"

run_locale_gen:
  cmd.run:
    - name: locale-gen
    - onchanges:
      - file: add_system_locale_en_gb_utf8

## Miscellaneous

MAILTO_root:
  cron.env_present:
    - name: MAILTO
    - value: sysadmin@open-contracting.org,code@opendataservices.coop,sysadmin@dogsbody.com
    - user: root

set_lc_all:
  file.append:
    - text: 'LC_ALL="en_GB.UTF-8"'
    - name: /etc/default/locale

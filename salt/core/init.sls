# The "core" directory defines base configuration steps that we want installed on all of our servers.
# The init.sls file contains the essential settings expected by other salt configs.

# git needs to be installed under its own ID (require: - pkg: git) to be referenced as a requisite.
# See https://github.com/saltstack/salt/issues/3683

# Install required packages.

# Nearly universal dependency.
git:
  pkg.installed

# Required for salt to interact with apt.
python-apt:
  pkg.installed

# Required for postfix configuration.
debconf-utils:
  pkg.installed

# Manage authorized keys for users with root access to all servers.
root_authorized_keys:
  ssh_auth.manage:
    - user: root
    - ssh_keys: {{ (pillar.ssh.admin + salt['pillar.get']('ssh:root', []))|yaml }}

# Several states add scripts to this directory.
/home/sysadmin-tools/bin:
  file.directory:
    - makedirs: True

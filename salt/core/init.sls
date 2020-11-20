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

# Upload SSH keys for users with access to all servers.
root_authorized_keys_add:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add

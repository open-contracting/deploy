# The "core" directory defines base configuration steps that we want installed on all of our servers.
# The init.sls file contains the essential settings expected by other salt configs.

# Install required packages.

# Required for most targets.
git:
  pkg.installed:
    - name: git

# Required for salt to interact with apt.
python-apt:
  pkg.installed:
    - name: python-apt

# Required for some targets.
debconf-utils:
  pkg.installed:
    - name: debconf-utils

# Several states add scripts to this directory.
/home/sysadmin-tools/bin:
  file.directory:
    - makedirs: True

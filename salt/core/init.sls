# The "core" directory defines base configuration steps that we want installed on all of our servers.
# The init.sls file contains the essential settings expected by other salt configs.

# Install required packages.

# Required for most targets.
git:
  pkg.installed:
    - name: git

# Required for salt to interact with apt.
python3-apt:
  pkg.installed:
    - name: python3-apt

# Required for some targets.
debconf-utils:
  pkg.installed:
    - name: debconf-utils

# Required for salt-extensions and some python applications.
pip:
  pkg.installed:
    - pkgs:
      - python3-pip
      - build-essential
      - python3-dev
    - install_recommends: False
  pip.installed:
    - name: pip
    - upgrade: True
{% if grains.osmajorrelease|int >= 24 %}
    # https://peps.python.org/pep-0668/
    - extra_args:
      - --break-system-packages
      - --ignore-installed
{% endif %}
    - require:
      - pkg: pip

# Several states add scripts to this directory.
/home/sysadmin-tools/bin:
  file.directory:
    - makedirs: True

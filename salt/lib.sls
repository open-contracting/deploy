# Defines common macros.
include:
  - aws

{% macro set_cron_env(user, name, value, scope="") %}
set {{ name }} environment variable in {{ user }} crontab{% if scope %} for {{ scope }}{% endif %}:
  cron.env_present:
    - name: {{ name }}
    - value: {{ value }}
    - user: {{ user }}
    - require:
      - user: {{ user }}_user_exists
{% endmacro %}

# Setting `require` to `file: /home/sysadmin-tools/{filename}` causes "Recursive requisite found".
{% macro set_config(filename, setting_name, setting_value="yes") %}
set {{ setting_name }} in {{ filename }}:
  file.keyvalue:
    - name: /home/sysadmin-tools/{{ filename }}
    - key: {{ setting_name }}
    - value: '"{{ setting_value }}"'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
{% endmacro %}

{% macro unset_config(filename, setting_name) %}
unset {{ setting_name }} in {{ filename }}:
  file.keyvalue:
    - name: /home/sysadmin-tools/{{ filename }}
    - key: {{ setting_name }}
    - value: '""'
    - ignore_if_missing: True
    - require:
      - file: /home/sysadmin-tools/bin
{% endmacro %}

{% macro set_firewall(setting_name, setting_value="yes") %}
{{ set_config('firewall-settings.local', setting_name, setting_value) }}
{% endmacro %}

{% macro unset_firewall(setting_name) %}
{{ unset_config('firewall-settings.local', setting_name) }}
{% endmacro %}

# It is safe to use `[]` as a default value, because the default value is never mutated.
{% macro create_user(user, uid=None, authorized_keys=[]) %}
{{ user }}_user_exists:
  user.present:
    - name: {{ user }}
    - home: /home/{{ user }}
{% if uid %}
    - uid: {{ uid }}
{% endif %}
    - order: 1
    - shell: /bin/bash
    # Fixed in next release after 3006.1 https://github.com/saltstack/salt/issues/64211
    - remove_groups: False

{{ user }}_authorized_keys:
  ssh_auth.manage:
    - user: {{ user }}
    - ssh_keys: {{ (pillar.ssh.admin + salt['pillar.get']('ssh:root', []) + authorized_keys)|yaml }}
    - require:
      - user: {{ user }}_user_exists
{% endmacro %}

{#
  Accepts an `entry` object with a `service` key for the name of the service, a `user` key for the user to run the
  service, and any other keys to be passed to the `*.service` template.
#}
# https://www.freedesktop.org/software/systemd/man/systemd.directives.html
{% macro systemd(entry) %}
/etc/systemd/system/{{ entry.service }}.service:
  file.managed:
    - source: salt://core/systemd/files/{{ entry.service }}.service
    - template: jinja
    - context:
        user: {{ entry.user }}
        group: {{ entry.group|default(entry.user) }}
        entry: {{ entry|yaml }}
    - watch_in:
      - service: {{ entry.service }}

{{ entry.service }}:
  service.running:
    - enable: True
    - require:
      - file: /etc/systemd/system/{{ entry.service }}.service

{{ entry.service }}-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ entry.service }}
{% endmacro %}

{#
  - parent_directory is a state that creates the parent directory (e.g. file.directory or git.latest).
  - requirements_file is a state that creates the requirements.txt file (e.g. file.managed or git.latest).
  - The calling state file must include the python.virtualenv state file (which includes the python state file).

  Bug: The "user" parameter is ignored, unless the undocumented "runas" parameter is used.
  https://github.com/saltstack/salt/issues/59088#issuecomment-912148651
#}
{% macro virtualenv(directory, user, parent_directory, requirements_file, watch_in) %}
{{ directory }}-virtualenv:
  virtualenv.managed:
    - name: {{ directory }}/.ve
    - python: /usr/bin/python{{ salt['pillar.get']('python:version', 3) }}
    - runas: {{ user }}
    - user: {{ user }}
    - require: {{ ([{'pkg': 'virtualenv'}] + [parent_directory])|yaml }}
{% if salt['pillar.get']('python:version') %}
    # If the Python version changes, reinstall the virtual environment.
    - watch:
      - pkg: python
{% endif %}

# Upgrade pip to avoid "ImportError: cannot import name 'html5lib' from 'pip._vendor'" (without using pip itself).
#
# The virtualenv.managed state calls the create function in the virtualenv_mod module. This function installs pip only
# if .ve/bin/pip doesn't exist (but it does, by default). ensurepip is simpler than get-pip.py.
{{ directory }}/.ve/bin/pip:
  # python3-venv is required for ensurepip to be available on Ubuntu.
  pkg.installed:
    - name: python{{ salt['pillar.get']('python:version', 3) }}-venv
  cmd.run:
    # https://pip.pypa.io/en/stable/installation/
    - name: {{ directory }}/.ve/bin/python -m ensurepip --upgrade
    - runas: {{ user }}
    - require:
      - pkg: {{ directory }}/.ve/bin/pip
    - onchanges:
      - virtualenv: {{ directory }}-virtualenv
    - watch_in:
      - virtualenv: {{ directory }}-piptools

# This state only differs from the *-virtualenv state by installing pip-tools and not watching python.
{{ directory }}-piptools:
  virtualenv.managed:
    - name: {{ directory }}/.ve
    - python: /usr/bin/python{{ salt['pillar.get']('python:version', 3) }}
    - runas: {{ user }}
    - user: {{ user }}
    - require: {{ ([{'pkg': 'virtualenv'}] + [parent_directory])|yaml }}
    - pip_pkgs:
      - pip-tools

{{ directory }}-requirements:
  cmd.run:
    - name: .ve/bin/pip-sync -q --pip-args "--exists-action w"
    - runas: {{ user }}
    - cwd: {{ directory }}
    - require:
      - virtualenv: {{ directory }}-piptools
    # Run the command if the virtual environment was reinstalled (64501d6) or the requirements file was changed.
    - onchanges: {{ ([{'virtualenv': directory + '-piptools'}] + [requirements_file])|yaml }}
{% if watch_in %}
    - watch_in:
      - service: {{ watch_in }}
{% endif %}
{% endmacro %}

{#
  Accepts a `name` string used to name configuration files, an `entry` object with Apache configuration, and a
  `context` object, whose keys are made available as variables in the configuration template.

  See https://ocdsdeploy.readthedocs.io/en/latest/develop/update/apache.html
#}
# It is safe to use `{}` as a default value, because the default value is never mutated.
{% macro apache(name, entry, context={}) %}
/etc/apache2/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://apache/files/sites/{{ entry.configuration }}.conf.include
    - template: jinja
    - context: {{ dict(context, name=name, **entry.get('context', {}))|yaml }}
    - require:
      - pkg: apache2
    - watch_in:
      - module: apache2-reload

/etc/apache2/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/files/sites/_common.conf
    - template: jinja
    - context:
        includefile: /etc/apache2/sites-available/{{ name }}.conf.include
        servername: {{ entry.servername }}
        serveraliases: {{ entry.serveraliases|default([])|yaml }}
        https: {{ entry.https|default(true) }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
    - watch_in:
      - module: apache2-reload

enable site {{ name }}.conf:
  apache_site.enabled:
    - name: {{ name }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf
    - watch_in:
      - module: apache2-reload

{% for username, password in entry.htpasswd|items %}
add .htpasswd-{{ name }}-{{ username }}:
  webutil.user_exists:
    - name: {{ username }}
    - password: {{ password }}
    - htpasswd_file: /etc/apache2/.htpasswd-{{ name }}
    - update: True
    - require:
      - pkg: apache2
{% endfor %}
{% endmacro %}

{#
  Accepts a `name` string used to name configuration files, an `entry` object with Nginx configuration, and a
  `context` object, whose keys are made available as variables in the configuration template.

  See https://ocdsdeploy.readthedocs.io/en/latest/develop/update/nginx.html
#}
{% macro nginx(name, entry, context={}) %}
{% if 'include' in entry %}
/etc/nginx/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://nginx/files/sites/{{ entry.include }}.conf.include
    - template: jinja
    - context: {{ dict(context, name=name, **entry.get('context', {}))|yaml }}
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload

/etc/nginx/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://nginx/files/sites/_common.conf
    - template: jinja
    - context:
        includefile: /etc/nginx/sites-available/{{ name }}.conf.include
        servername: {{ entry.servername }}
        serveraliases: {{ entry.serveraliases|default([])|yaml }}
    - require:
      - file: /etc/nginx/sites-available/{{ name }}.conf.include
    - watch_in:
      - module: nginx-reload
{% else %}
/etc/nginx/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://nginx/files/sites/{{ entry.configuration }}.conf
    - template: jinja
    - context: {{ dict(context, servername=entry.servername, serveraliases=entry.get('serveraliases', []), **entry.get('context', {}))|yaml }}
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload
{% endif %}

/etc/nginx/sites-enabled/{{ name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ name }}.conf
    - require:
      - file: /etc/nginx/sites-available/{{ name }}.conf
    - watch_in:
      - module: nginx-reload
{% endmacro %}


{% macro aws_site_backup(userdir, backup_location) %}
{{ set_config('aws-settings.local', 'S3_SITE_BACKUP_BUCKET', backup_location) }}

/home/sysadmin-tools/bin/site-backup-to-s3.sh:
  file.managed:
    - source: salt://files/site-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws

/etc/cron.d/site_file_backup:
  file.managed:
    - contents: |
        MAILTO=root
        15 04 * * * root /home/sysadmin-tools/bin/site-backup-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/site-backup-to-s3.sh

set BACKUP_DIRECTORIES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: BACKUP_DIRECTORIES
    - value: ( "{{ userdir }}/public_html/" )
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
{% endmacro %}

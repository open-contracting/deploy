# Defines common macros.

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
{% macro virtualenv(directory, user, parent_directory, requirements_file, watch_in=None) %}
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

# This state only differs from the *-virtualenv state by installing uv and not watching python.
{{ directory }}-uv:
  virtualenv.managed:
    - name: {{ directory }}/.ve
    - python: /usr/bin/python{{ salt['pillar.get']('python:version', 3) }}
    - runas: {{ user }}
    - user: {{ user }}
    - require: {{ ([{'pkg': 'virtualenv'}] + [parent_directory])|yaml }}
    - pip_pkgs:
      - uv

{{ directory }}-requirements:
  cmd.run:
    - name: .ve/bin/uv pip sync --python=.ve/bin/python -q requirements.txt
    - runas: {{ user }}
    - cwd: {{ directory }}
    - require:
      - virtualenv: {{ directory }}-uv
    # Run the command if the virtual environment was reinstalled (64501d6) or the requirements file was changed.
    - onchanges: {{ ([{'virtualenv': directory + '-uv'}] + [requirements_file])|yaml }}
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
        log_directory: /var/log/apache2/{{ name }}
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

{% if pillar.apache.site_logs|default(False) and not name[0:1].isdigit() %}
/var/log/apache2/{{ name }}:
  file.directory:
    - user: root
    - group: adm
    - dir_mode: 755
    - require_in:
      - file: /etc/apache2/sites-available/{{ name }}.conf
{% endif%}
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

{% macro logrotate(name, entry={}) %}
/etc/logrotate.d/{{ name }}:
  file.managed:
    - source: salt://core/logrotate/files/{{ entry.source|default(name) }}
{% if 'context' in entry %}
    - template: jinja
    - context: {{ entry.context|yaml }}
{% endif %}
{% endmacro %}

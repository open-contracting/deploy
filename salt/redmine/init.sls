{% from 'lib.sls' import create_user %}

{% set user = 'redmine' %}
{% set branch = '5.0-stable' %}
{% set revision = 21893 %}
{% set theme = 'circle' %}

include:
  - apache
  - apache.modules.passenger
  - mysql
  - rvm

{{ create_user(user) }}

/home/{{ user }}/public_html:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

# https://redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_50x_on_Ubuntu_2004_with_Apache2
redmine:
  pkg.installed:
    - pkgs:
      - subversion
      - ruby-dev
      - libmysqlclient-dev
      # https://www.redmine.org/projects/redmine/wiki/redmineinstall#Optional-components
      - ghostscript
      - imagemagick
  gem.installed:
    - name: bundler
  svn.latest:
    - name: https://svn.redmine.org/redmine/branches/{{ branch }}
    - target: /home/{{ user }}/public_html
    - rev: {{ revision }}
    - require:
      - file: /home/{{ user }}/public_html
      - pkg: redmine
      - gem: redmine
    - watch_in:
      - service: apache2

# Ensure permissions are correct.
# https://www.redmine.org/projects/redmine/wiki/redmineinstall#Step-8-File-system-permissions
set redmine directory permissions:
  file.directory:
    - names:
      - /home/{{ user }}/public_html/tmp
      - /home/{{ user }}/public_html/files
      - /home/{{ user }}/public_html/log
      - /home/{{ user }}/public_html/public/plugin_assets
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: {{ user }}_user_exists
      - svn: redmine

set redmine file permissions:
  file.managed:
    - names:
      - /home/{{ user }}/public_html/config.ru
      - /home/{{ user }}/public_html/Gemfile.lock
    - replace: False
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists
      - svn: redmine

/home/{{ user }}/public_html/config/database.yml:
  file.serialize:
    # https://redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_50x_on_Ubuntu_2004_with_Apache2#Edit-database-configuration-file
    - dataset:
        production:
          adapter: mysql2
          host: localhost
          database: redmine
          username: redmine
          password: "{{ pillar.mysql.users.redmine.password }}"
          encoding: utf8mb4
    - serializer: yaml
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - require:
      - user: {{ user }}_user_exists
      - svn: redmine
    - watch_in:
      - service: apache2

## Disabled until server go live.
#/home/{{ user }}/public_html/config/configuration.yml:
#  file.serialize:
#    - dataset_pillar: redmine:configuration
#    - serializer: yaml
#    - user: {{ user }}
#    - group: {{ user }}
#    - mode: 640
#    - require:
#      - user: {{ user }}_user_exists
#      - svn: redmine
#    - watch_in:
#      - service: apache2

/home/{{ user }}/public_html/public/themes/{{ theme }}:
  file.recurse:
    - source: salt://private/files/redmine/{{ theme }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists
      - svn: redmine
    - watch_in:
      - service: apache2

{% for plugin in ['redmine_agile', 'redmine_checklists', 'redmine_contacts', 'redmine_contacts_helpdesk', 'view_customize'] %}
/home/{{ user }}/public_html/plugins/{{ plugin }}:
  file.recurse:
    - source: salt://private/files/redmine/{{ plugin }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists
      - svn: redmine
    - watch_in:
      - service: apache2
{% endfor %}

/home/sysadmin-tools/bin/redmine_cron.sh:
  file.managed:
    - source: salt://redmine/files/redmine_cron.sh
    - mode: 750
    - template: jinja
    - require:
      - file: /home/sysadmin-tools/bin

## Disabled until server go live.
#/etc/cron.d/redmine:
#  file.managed:
#    - text: |
#      MAILTO=root
#      */5 * * * * root /bin/bash /home/sysadmin-tools/bin/redmine_cron.sh
#    - require:
#      - file: /home/sysadmin-tools/bin/site-backup-to-s3.sh

{{ create_user("report_user", authorized_keys=salt['pillar.get']('ssh:report_user', [])) }}

grant report user readonly privileges:
  mysql_grants.present:
    - grant: SELECT
    - database: redmine.*
    - user: report
    - require:
      - mysql_user: report_mysql_user
      - mysql_database: redmine_mysql_database

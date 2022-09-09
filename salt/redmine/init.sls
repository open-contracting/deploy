{% from 'lib.sls' import apache, create_user %}

{% set user = 'redmine' %}
{% set branch = '5.0-stable' %}
{% set revision = 21783 %}

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
redmine dependencies:
  pkg.installed:
    - pkgs:
      - ruby-dev
      - libncurses5-dev
      - libmysqlclient-dev
      # https://www.redmine.org/projects/redmine/wiki/redmineinstall#Optional-components
      - ghostscript
      - imagemagick
    - require:
      - pkg: libapache2-mod-passenger
      - rvm: ruby-{{ pillar.rvm.default_version }}

redmine:
  pkg.installed:
    - name: subversion
  svn.latest:
    - name: https://svn.redmine.org/redmine/branches/{{ branch }}
    - target: /home/{{ user }}/public_html
    - rev: {{ revision }}
    - require:
      - pkg: redmine
      - file: /home/{{ user }}/public_html

set redmine directory permissions:
  file.directory:
    - names:
      - /home/{{ user }}/public_html/tmp
      - /home/{{ user }}/public_html/files
      - /home/{{ user }}/public_html/log
      - /home/{{ user }}/public_html/public/plugin_assets
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - recurse:
      - user
      - group
      - mode
      - ignore_files
    - require:
      - user: {{ user }}_user_exists

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

{% for plugin in ['redmine_agile', 'redmine_checklists', 'redmine_contacts', 'redmine_contacts_helpdesk', 'view_customize'] %}
/home/{{ user }}/public_html/plugins/{{ plugin }}:
  file.recurse:
    - source: salt://private/files/redmine/{{ plugin }}
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

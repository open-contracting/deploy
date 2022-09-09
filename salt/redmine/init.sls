{% from 'lib.sls' import apache, create_user %}

include:
  - apache
  - apache.modules.passenger
  - mysql
  - rvm

{{ create_user(pillar.redmine.user) }}

/home/{{ pillar.redmine.user }}/public_html:
  file.directory:
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - require:
      - user: {{ pillar.redmine.user }}_user_exists

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
      - rvm: ruby-{{ pillar.ruby_version }}

redmine:
  pkg.installed:
    - name: subversion
  svn.latest:
    - name: https://svn.redmine.org/redmine/branches/{{ pillar.redmine.svn.branch }}
    - target: /home/{{ pillar.redmine.user }}/public_html
    - rev: {{ pillar.redmine.svn.revision }}
    - require:
      - pkg: redmine
      - file: /home/{{ pillar.redmine.user }}/public_html

set redmine directory permissions:
  file.directory:
    - names:
      - /home/{{ pillar.redmine.user }}/public_html/tmp
      - /home/{{ pillar.redmine.user }}/public_html/files
      - /home/{{ pillar.redmine.user }}/public_html/log
      - /home/{{ pillar.redmine.user }}/public_html/public/plugin_assets
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - mode: 755
    - recurse:
      - user
      - group
      - mode
      - ignore_files
    - require:
      - user: {{ pillar.redmine.user }}_user_exists

set redmine file permissions:
  file.managed:
    - names:
      - /home/{{ pillar.redmine.user }}/public_html/config.ru
      - /home/{{ pillar.redmine.user }}/public_html/Gemfile.lock
    - replace: False
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - require:
      - user: {{ pillar.redmine.user }}_user_exists

/home/{{ pillar.redmine.user }}/public_html/config/database.yml:
  file.serialize:
    # https://redmine.org/projects/redmine/wiki/HowTo_Install_Redmine_50x_on_Ubuntu_2004_with_Apache2#Edit-database-configuration-file
    - dataset:
        production:
          adapter: mysql2
          host: localhost
          database: {{ pillar.redmine.database.name }}
          username: {{ pillar.redmine.database.user }}
          password: "{{ pillar.redmine.database.password }}"
          encoding: utf8mb4
    - serializer: yaml
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - mode: 640
    - require:
      - user: {{ pillar.redmine.user }}_user_exists

{% for plugin in pillar.redmine.get('plugins', []) %}
/home/{{ pillar.redmine.user }}/public_html/plugins/{{ plugin }}:
  file.recurse:
    - source: salt://private/files/redmine/{{ plugin }}
    - require:
      - user: {{ pillar.redmine.user }}_user_exists
{% endfor %}

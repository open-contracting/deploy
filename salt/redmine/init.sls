{% from 'lib.sls' import apache, create_user %}

include:
  - apache
  - mysql
  - passenger

{{ create_user(pillar.redmine.user) }}

/home/{{ pillar.redmine.user }}/public_html:
  file.directory:
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - require:
      - user: {{ pillar.redmine.user }}_user_exists

redmine dependencies:
  pkg.installed:
    - pkgs:
      - subversion
      - ruby-dev
      - libncurses5-dev
      - libmysqlclient-dev
      - ghostscript
      - imagemagick
    - require:
      - pkg: libapache2-mod-passenger
      - rvm: ruby-{{ pillar.ruby_version }}

# Deploy redmine code 
redmine deploy:
  svn.latest:
    - name: https://svn.redmine.org/redmine/branches/{{ pillar.redmine.svn.branch }}
    - target: /home/{{ pillar.redmine.user }}/public_html
    - rev: {{ pillar.redmine.svn.revision }}
    - require:
      - pkg: redmine dependencies
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

set redmine file permissions:
  file.managed:
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - replace: False
    - names:
      - /home/{{ pillar.redmine.user }}/public_html/config.ru
      - /home/{{ pillar.redmine.user }}/public_html/Gemfile.lock

/home/{{ pillar.redmine.user }}/public_html/config/database.yml:
  file.managed:
    - source: salt://redmine/files/config/{{ pillar.redmine.config }}.yml
    - template: jinja
    - user: {{ pillar.redmine.user }}
    - group: {{ pillar.redmine.user }}
    - mode: 640

# Deploy plugins from salt/private
{% if pillar.redmine.get('plugins') %}
{% for plugin_name in pillar.redmine.plugins %}
/home/redmine/public_html/plugins/{{ plugin_name }}:
  file.recurse:
    - source: salt://private/redmine-plugins/{{ plugin_name }}
{% endfor %}
{% endif %}

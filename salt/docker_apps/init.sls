include:
  - docker

# Trailing slash for easy concatenation.
{% set docker_apps_directory = '/data/deploy/' %}

{% for name, entry in pillar.docker_apps|items %}
{% set directory = docker_apps_directory + entry.target %}

{{ directory }}/docker-compose.yaml:
  file.managed:
    - source: salt://docker_apps/files/{{ entry.configuration|default(name) }}.yaml
    - template: jinja
    - context:
        directory: {{ directory }}
        entry: {{ entry|yaml }}
{% if 'site' in entry %}
  {% if 'apache' in pillar %}
        site: {{pillar.apache.sites[entry.site].context|yaml }}
  {% else %}
        site: {{pillar.nginx.sites[entry.site].context|yaml }}
  {% endif %}
{% endif %}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

{{ directory }}/.env:
  file.managed:
    - source: salt://docker_apps/files/.env
    - template: jinja
    - context:
        entry: {{ entry|yaml }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - mode: 400
    - require:
      - user: {{ pillar.docker.user }}_user_exists

{% for volume in entry.volumes|default([]) %}
{{ entry.host_dir|default(directory) }}/{{ volume }}:
  file.directory:
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
{% endfor %}

{% if 'redis' in entry.volumes | join(' ') %}
{{ directory }}/redis/redis.conf:
  file.managed:
    - source: salt://docker_apps/files/conf/redis.conf
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
{% endif %}
{% endfor %}

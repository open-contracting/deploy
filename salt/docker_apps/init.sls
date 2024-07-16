include:
  - docker

# Trailing slash for easy concatenation.
{% set docker_apps_directory = '/data/deploy/' %}

{% for name, entry in pillar.docker_apps|items %}
{% set directory = docker_apps_directory + entry.target %}

{{ directory }}/docker-compose.yaml:
  file.managed:
    - source: salt://docker_apps/files/{{ name }}.yaml
    - template: jinja
    - context:
        directory: {{ directory }}
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
{% endfor %}

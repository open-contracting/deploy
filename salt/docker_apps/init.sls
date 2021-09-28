include:
  - docker

{% for name, entry in pillar.docker_apps.items() %}
{% if 'target' in entry %}

{% set directory = '/data/deploy/' + entry.target %}

{{ directory }}/docker-compose.yaml:
  file.managed:
    - source: salt://docker_apps/files/{{ name }}.yaml
    - template: jinja
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

{% if 'env' in entry %}
{{ directory }}/env:
  file.managed:
    - source: salt://docker_apps/files/env
    - template: jinja
    - context:
        entry: {{ entry|yaml }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - mode: 400
    - require:
      - user: {{ pillar.docker.user }}_user_exists
{% endif %}

{% endif %}
{% endfor %}

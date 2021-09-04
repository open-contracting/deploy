include:
  - docker

{% for name, entry in pillar.docker_apps.items() %}
{% if entry.target %}

{% set directory = '/data/deploy/' + entry.target %}

{{ directory }}/docker-compose.yaml:
  file.managed:
    - source: salt://registry/files/{{ name }}.yaml
    - template: jinja
    - makedirs: True

{% if entry.env %}
{{ directory }}/env:
  file.managed:
    - source: salt://registry/files/env
    - template: jinja
    - makedirs: True
    - context:
        entry: {{ entry|yaml }}
    - mode: 400
{% endif %}

{% endif %}
{% endfor %}

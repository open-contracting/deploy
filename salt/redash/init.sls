{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.redash %}
{% set directory = docker_apps_directory + entry.target %}

{{ directory }}/files/nginx-security.conf:
  file.managed:
    - contents: |
        server_tokens off;
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

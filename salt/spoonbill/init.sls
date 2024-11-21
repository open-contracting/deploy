include:
  - docker_apps

{% set entry = pillar.docker_apps.spoonbill %}

{{ entry.host_dir }}:
  file.directory:
    - names:
      - {{ entry.host_dir }}/media
      - {{ entry.host_dir }}/tmp
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

{{ entry.host_dir }}/redis:
  file.directory:
    - names:
      - {{ entry.host_dir }}/redis/data
      - {{ entry.host_dir }}/redis/tmp
    # https://github.com/bitnami/containers/blob/main/bitnami/redis/README.md#persisting-your-database
    - user: 1001
    - group: 1001
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

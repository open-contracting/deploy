include:
  - docker_apps

/data/deploy/redash/files/nginx-security.conf:
  file.managed:
    - contents: |
       server_tokens off;
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

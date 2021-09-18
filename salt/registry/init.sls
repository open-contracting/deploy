{% from 'lib.sls' import create_user %}

include:
- registry.database
- docker_apps

{{ create_user(pillar.docker.user) }}

{% from 'lib.sls' import create_user %}

# https://docs.docker.com/engine/install/ubuntu/
docker:
  pkgrepo.managed:
    - humanname: Docker Official Repository
    {% if grains.osmajorrelease | string in ("18", "20") %}
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/{{ grains.kernel|lower }}/{{ grains.os|lower }} {{ grains.oscodename }} stable
    {% else %}
    - name: deb [arch={{ grains.osarch }} signed-by=/usr/share/keyrings/docker-keyring.gpg] https://download.docker.com/{{ grains.kernel|lower }}/{{ grains.os|lower }} {{ grains.oscodename }} stable
    - aptkey: False
    {% endif %}
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/{{ grains.kernel|lower }}/{{ grains.os|lower }}/gpg
  pkg.installed:
    - name: docker-ce
    - require:
      - pkgrepo: docker
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker

# https://docs.docker.com/config/containers/logging/configure/
# https://docs.docker.com/config/containers/logging/local/
# https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
# https://docs.docker.com/engine/install/linux-postinstall/#configure-default-logging-driver
/etc/docker/daemon.json:
  file.managed:
    - source: salt://docker/files/daemon.json
    - require:
      - pkg: docker
    - watch_in:
      - service: docker

{% if salt['pillar.get']('docker:user') %}
{{ create_user(pillar.docker.user, uid=pillar.docker.get('uid')) }}

# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
add {{ pillar.docker.user }} user to docker group:
  group.present:
    - name: docker
    - addusers:
      - {{ pillar.docker.user }}
    - require:
      - user: {{ pillar.docker.user }}_user_exists
{% endif %}

{% if salt['pillar.get']('docker:docker_compose:version') %}
# https://docs.docker.com/compose/install/
/usr/local/bin/docker-compose:
  file.managed:
    - source: https://github.com/docker/compose/releases/download/{{ pillar.docker.docker_compose.version }}/docker-compose-{{ grains.kernel }}-{{ grains.cpuarch }}
    - source_hash: https://github.com/docker/compose/releases/download/{{ pillar.docker.docker_compose.version }}/docker-compose-{{ grains.kernel }}-{{ grains.cpuarch }}.sha256
    - mode: 755
{% endif %}

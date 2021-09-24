# https://docs.docker.com/engine/install/ubuntu/
docker:
  pkgrepo.managed:
    - humanname: Docker Official Repository
    - name: deb [arch={{ grains.osarch }}] https://download.docker.com/{{ grains.kernel|lower }}/{{ grains.os|lower }} {{ grains.oscodename }} stable
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
  # https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
  group.present:
    - addusers:
      - {{ pillar.docker.user }}

# https://docs.docker.com/config/containers/logging/configure/
# https://docs.docker.com/config/containers/logging/local/
/etc/docker/daemon.json:
  file.managed:
    - source: salt://docker/files/daemon.json
    - require:
      - pkg: docker
    - watch_in:
      - service: docker

# https://docs.docker.com/compose/install/
/usr/local/bin/docker-compose:
  file.managed:
    - source: https://github.com/docker/compose/releases/download/{{ pillar.docker.docker_compose.version }}/docker-compose-{{ grains.kernel }}-{{ grains.cpuarch }}
    - source_hash: https://github.com/docker/compose/releases/download/{{ pillar.docker.docker_compose.version }}/docker-compose-{{ grains.kernel }}-{{ grains.cpuarch }}.sha256
    - mode: 755

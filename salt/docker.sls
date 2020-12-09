# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository

docker_prepackages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - gnupg-agent
      - software-properties-common

docker:
  pkgrepo.managed:
    - humanname: Docker Official Repository
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains['oscodename'] }} stable
    - dist: {{ grains['oscodename'] }}
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require:
      - pkg: docker_prepackages
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - require:
      - pkgrepo: docker

# currently 1.22.0 because this is what is used in https://github.com/getredash/setup/blob/master/setup.sh#L18
/usr/local/bin/docker-compose:
  file.managed:
    - source: https://github.com/docker/compose/releases/download/1.22.0/docker-compose-{{ grains['kernel'] }}-{{ grains['cpuarch'] }}
    - source_hash: https://github.com/docker/compose/releases/download/1.22.0/docker-compose-{{ grains['kernel'] }}-{{ grains['cpuarch'] }}.sha256
    - mode: 755

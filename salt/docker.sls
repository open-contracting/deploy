# https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository
#
# This assumes you are installing on Ubuntu Bionic.

docker_prepackages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - curl
      - gnupg-agent
      - software-properties-common

docker_repo:
  pkgrepo.managed:
    - humanname: Docker Official Repository
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
    - dist: bionic
    - file: /etc/apt/sources.list.d/docker.list
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - require:
      - pkg: docker_prepackages

docker:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
    - refresh: True
    - require:
      - pkgrepo: docker_repo

# currently 1.22.0 because this is what is used in https://github.com/getredash/setup/blob/master/setup.sh#L18
docker-compose:
  cmd.run:
    - name: curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose; chmod u+x /usr/local/bin/docker-compose
    - creates: /usr/local/bin/docker-compose

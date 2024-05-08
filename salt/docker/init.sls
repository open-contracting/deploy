{% from 'lib.sls' import create_user %}

# https://docs.docker.com/engine/install/ubuntu/
docker:
  pkgrepo.managed:
    - humanname: Docker Official Repository
    {% if grains.osmajorrelease | string in ('18', '20') %}
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

{% if pillar.docker.get('syslog_logging') %}
/var/log/docker-custom:
  file.directory:
    - user: root
    - group: syslog
    - mode: 0775
{% endif %}

{% if salt['pillar.get']('rabbitmq') %}
# If RabbitMQ is installed, ensure it is online before and after Docker.
/etc/systemd/system/docker.service.d/customization.conf:
  file.managed:
    - contents: |
        [Unit]
        After=rabbitmq-server.service
        Wants=rabbitmq-server.service
    - makedirs: True
    - watch_in:
      - service: docker
{% endif %}

# https://docs.docker.com/config/containers/logging/configure/
# https://docs.docker.com/config/containers/logging/local/
# https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
# https://docs.docker.com/engine/install/linux-postinstall/#configure-default-logging-driver
/etc/docker/daemon.json:
  file.managed:
    {% if pillar.docker.get('syslog_logging') %}
    # https://docs.docker.com/config/containers/logging/log_tags/
    - source: salt://docker/files/daemon-logging.json
    {% else %}
    - source: salt://docker/files/daemon.json
    {% endif %}
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

/home/{{ pillar.docker.user }}/.pgpass:
  file.managed:
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - mode: 400
    - require:
      - user: {{ pillar.docker.user }}_user_exists

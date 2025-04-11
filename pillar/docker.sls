rsyslog:
  conf:
    10-docker.conf: docker.conf

logrotate:
  conf:
    docker:
      source: docker

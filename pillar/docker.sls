rsyslog:
  conf:
    80-docker.conf: docker.conf

logrotate:
  conf:
    docker:
      source: docker

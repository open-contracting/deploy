rsyslog:
  conf:
    80-docker.conf: docker.conf

logrotate:
  conf:
    docker:
      source: docker

apache:
  public_access: True
  sites:
    cove:
      configuration: django
      context:
        port: 8000
        static_port: 8001
        timeout: 1800 # 30 min

docker:
  user: deployer
  uid: 1003
  syslog_logging: True

docker_apps:
  cove:
    target: cove
    host_dir: /data/storage/cove
    env:
      DJANGO_PROXY: True
      SECURE_HSTS_SECONDS: 31536000
      GUNICORN_CMD_ARGS: --workers 3
      # lib-cove-web
      DELETE_FILES_AFTER_DAYS: 90 # default 7
      REQUESTS_TIMEOUT: 10 # default None
      VALIDATION_ERROR_LOCATIONS_LENGTH: 100 # default 1000
      # https://github.com/requests-cache/requests-cache/blob/main/requests_cache/policy/expiration.py
      REQUESTS_CACHE_EXPIRE_AFTER: 0 # EXPIRE_IMMEDIATELY

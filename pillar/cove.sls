x-volumes: &volumes
  - db
  - media
  - redis/data
  - redis/tmp

x-env: &env
  DJANGO_PROXY: True
  SECURE_HSTS_SECONDS: 31536000
  # https://github.com/requests-cache/requests-cache/blob/main/requests_cache/policy/expiration.py
  REQUESTS_CACHE_EXPIRE_AFTER: 0 # EXPIRE_IMMEDIATELY

network:
  host_id: ocp28
  ipv4: 66.228.47.174
  ipv6: "2600:3c03:e000:021e::"
  networkd:
    template: linode
    gateway4: 66.228.47.1

vm:
  # For Redis service in cove.yaml.
  overcommit_memory: 1

ntp:
  - 0.us.pool.ntp.org
  - 1.us.pool.ntp.org
  - 2.us.pool.ntp.org
  - 3.us.pool.ntp.org

apache:
  public_access: True
  sites:
    cove-ocds:
      configuration: django
      servername: review.standard.open-contracting.org
      context:
        port: 8000
        static_port: 8001
        timeout: 1800 # 30 min
    cove-oc4ids:
      configuration: django
      servername: review-oc4ids.standard.open-contracting.org
      context:
        port: 8002
        static_port: 8003
        timeout: 1800 # 30 min

docker:
  user: deployer
  uid: 1003
  syslog_logging: True

docker_apps:
  cove_ocds:
    configuration: cove
    target: cove-ocds
    site: cove-ocds
    image: cove-ocds
    volumes: *volumes
    env:
      <<: *env
      ALLOWED_HOSTS: review.standard.open-contracting.org
      FATHOM_ANALYTICS_ID: PPQKEZDX
      GUNICORN_CMD_ARGS: --workers 3
  cove_oc4ids:
    configuration: cove
    target: cove-oc4ids
    site: cove-oc4ids
    image: cove-oc4ids
    volumes: *volumes
    env:
      <<: *env
      ALLOWED_HOSTS: review-oc4ids.standard.open-contracting.org
      FATHOM_ANALYTICS_ID: UHUGOEOK
      REDIS_URL: redis://redis:6379/0

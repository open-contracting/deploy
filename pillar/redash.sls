network:
  host_id: ocp14
  ipv4: 139.162.199.85
  ipv6: 2a01:7e00:e000:02cc::14
  netplan:
    configuration: linode
    addresses:
      - 2a01:7e00::f03c:92ff:fea5:0e5f/64    # SLAAC
    gateway4: 139.162.199.1
    gateway6: fe80::1

vm:
  nr_hugepages: 128

apache:
  public_access: True
  sites:
    redash:
      configuration: proxy
      servername: redash.open-contracting.org
      context:
        proxypass: http://localhost:9090/

postgres:
  version: 13
  # Docker containers don't use localhost to connect to the host's PostgreSQL service. Public access is controlled using Linode's firewall.
  public_access: True
  configuration: redash

docker:
  user: deployer
  docker_compose:
    version: 1.29.2

docker_apps:
  redash:
    target: redash
    env:
      PYTHONUNBUFFERED: '0'
      REDASH_LOG_LEVEL: INFO
      REDASH_REDIS_URL: redis://redis:6379/0
      REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL: 'true'
      REDASH_MAIL_SERVER: email-smtp.us-east-1.amazonaws.com
      REDASH_MAIL_PORT: 587
      REDASH_MAIL_USE_TLS: 'true'
      REDASH_MAIL_DEFAULT_SENDER: noreply@noreply.open-contracting.org
      REDASH_HOST: https://redash.open-contracting.org

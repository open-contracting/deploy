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
    credere:
      configuration: credere
      context:
        port: 8001
        static_port: 8000

docker:
  user: deployer
  syslog_logging: True

docker_apps:
  credere_frontend:
    target: credere-frontend
  credere_backend:
    target: credere-backend
    env:
      LOG_LEVEL: WARNING
      # Security
      MAX_FILE_SIZE_MB: 5 # sync with VITE_MAX_FILE_SIZE_MB
      # Email addresses
      EMAIL_SENDER_ADDRESS: credere@noreply.open-contracting.org
      # Email templates
      EMAIL_TEMPLATE_LANG: es

postgres:
  version: 15
  # Docker containers don't use localhost to connect to the host's PostgreSQL service. Public access is controlled using Linode's firewall.
  public_access: True
  configuration:
    name: credere
    source: shared
    context:
      storage: ssd
  databases:
    credere:
      user: credere

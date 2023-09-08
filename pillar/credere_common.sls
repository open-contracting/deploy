apache:
  public_access: True
  sites:
    credere:
      configuration: credere
      context:
        # Need to sync with `docker_apps.credere_backend.port`.
        port: 8001
        # Need to sync with `docker_apps.credere_frontend.port`.
        port_static: 8000

docker:
  user: deployer
  uid: 1000

docker_apps:
  credere_frontend:
    target: credere-frontend
    port: 8000
  credere_backend:
    target: credere-backend
    port: 8001
    env:
      EMAIL_TEMPLATE_LANG: en
      MAX_FILE_SIZE_MB: 5 # sync with VITE_MAX_FILE_SIZE_MB
      # Email addresses
      EMAIL_SENDER_ADDRESS: credere@noreply.open-contracting.org
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      OCP_EMAIL_GROUP: credereadmin@open-contracting.org
      # Email templates
      FACEBOOK_LINK: https://www.facebook.com/OpenContracting/
      TWITTER_LINK: https://twitter.com/opencontracting

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

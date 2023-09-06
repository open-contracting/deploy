apache:
  public_access: True
  sites:
    credere:
      configuration: proxy
      # servername: credere.open-contracting.org
      context:
        proxypass: http://localhost:8000/
        # authname: Credere Staging

docker:
  user: deployer
  docker_compose:
    version: v2.19.0

docker_apps:
  credere_frontend:
    target: credere-frontend
    port: 8000
    env:
      # Vite
      VITE_APP_VERSION: 0.1.5
      VITE_CURRENCY: COP
      VITE_DEFAULT_LANG: es
      VITE_LOCALE: es-CO
      VITE_MAX_FILE_SIZE_MB: 5
      VITE_MORE_INFO_OCP_URL: https://www.open-contracting.org/es/
  credere_backend:
    target: credere-backend
    port: 3000
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

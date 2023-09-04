network:
  host_id: ocp24
  ipv4: 213.52.130.126
  ipv6: "2a01:7e00:e000:06e6::"
  networkd:
    template: linode
    gateway4: 213.52.130.1

apache:
  public_access: True
  sites:
    credere:
      configuration: proxy
      servername: ocp24.open-contracting.org
      # servername: credere.open-contracting.org
      context:
        proxypass: http://localhost:8000/
        # authname: Credere Staging

docker:
  user: deployer

docker_apps:
  credere:
    target: credere
    env:
      FRONTEND_URL: https://ocp24.open-contracting.org # https://credere.open-contracting.org
      EMAIL_TEMPLATE_LANG: en
      ENVIRONMENT: development
      MAX_FILE_SIZE_MB: 5 # sync with VITE_MAX_FILE_SIZE_MB
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      DAYS_TO_CHANGE_TO_LAPSED: 1
      DAYS_TO_ERASE_BORROWERS_DATA: 1
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      REMINDER_DAYS_BEFORE_EXPIRATION: 2
      # Email addresses
      EMAIL_SENDER_ADDRESS: credere@noreply.open-contracting.org
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      OCP_EMAIL_GROUP: credereadmin@open-contracting.org
      # Email templates
      FACEBOOK_LINK: www.facebook.com
      TWITTER_LINK: www.twitter.com
      LINK_LINK: https://ocp24.open-contracting.org # https://credere.open-contracting.org
      IMAGES_BASE_URL: https://ocp24.open-contracting.org/images # https://credere.open-contracting.org/images
      # Vite
      VITE_API_URL: https://ocp24.open-contracting.org/api # https://credere.open-contracting.org/api
      VITE_APP_VERSION: 0.1.5
      VITE_CURRENCY: COP
      VITE_DEFAULT_LANG: es
      VITE_HOST: ocp24.open-contracting.org # credere.open-contracting.org
      VITE_LOCALE: es-CO
      VITE_MAX_FILE_SIZE_MB: 5
      VITE_MORE_INFO_OCP_URL: https://www.open-contracting.org/es/

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

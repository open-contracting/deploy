network:
  host_id: ocp22
  ipv4: 178.79.139.218
  ipv6: "2a01:7e00:e000:04e8::"
  networkd:
    template: linode
    gateway4: 178.79.139.1

apache:
  public_access: True
  sites:
    credere:
      configuration: proxy
      servername: ocp22.open-contracting.org
      # servername: credere.open-contracting.org
      context:
        proxypass: http://localhost:8000/
        # authname: Credere Staging

docker:
  user: deployer
  docker_compose:
    version: v2.19.0

docker_apps:
  credere:
    target: credere
    env:
      EMAIL_SENDER_ADDRESS: credere@noreply.open-contracting.org
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      FRONTEND_URL: https://ocp22.open-contracting.org # https://credere.open-contracting.org
      # Email templates
      FACEBOOK_LINK: www.facebook.com
      TWITTER_LINK: www.twitter.com
      LINK_LINK: https://ocp22.open-contracting.org # https://credere.open-contracting.org
      IMAGES_BASE_URL: https://ocp22.open-contracting.org/images # https://credere.open-contracting.org/images
      IMAGES_LANG_SUBPATH: en
      # Vite
      VITE_APP_VERSION: 0.1.3
      VITE_API_URL: https://ocp22.open-contracting.org/api # https://credere.open-contracting.org/api
      VITE_HOST: ocp22.open-contracting.org # credere.open-contracting.org
      VITE_DEFAULT_LANG: es

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

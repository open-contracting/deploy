network:
  host_id: ocp22
  ipv4: 178.79.139.218
  networkd:
    template: linode
    gateway4: 178.79.139.1

apache:
  public_access: True
  sites:
    credere:
      configuration: proxy
      servername: credere.open-contracting.org
      context:
        proxypass: http://localhost:8000/
        authname: Credere Staging

docker:
  user: deployer
  docker_compose:
    version: v2.18.1

docker_apps:
  credere:
    target: credere
    env:
      EMAIL_SENDER_ADDRESS: credere@noreply.open-contracting.org
      FRONTEND_URL: 

postgres:
  version: 15
  # Docker containers don't use localhost to connect to the host's PostgreSQL service. Public access is controlled using Linode's firewall.
  public_access: True
  configuration: False
  databases:
    credere:
      user: credere

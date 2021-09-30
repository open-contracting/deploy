apache:
  public_access: True
  sites:
    redash:
      configuration: proxy
      servername: redash.open-contracting.org
      context:
        proxypass: http://localhost:9090/

docker:
  docker_compose:
    version: 1.29.2

redash:
  docker_tag: redash/redash:10.0.0-beta.b49597
  postgres:
    username: redash_user
    hostname: ocp14.open-contracting.org
    database: redash_db
  mail:
    server: email-smtp.us-east-1.amazonaws.com
    port: 587
    default_sender: noreply@noreply.open-contracting.org
  host: https://redash.open-contracting.org

postgres:
  version: 13
  # Redash connection to postgres are not sent over the localhost connection.
  # Postgres access is locked down further in the Linode firewall.
  public_access: true
  configuration: redash
  storage: ssd
  type: oltp
  nr_hugepages: 128

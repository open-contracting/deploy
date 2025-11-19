network:
  host_id: ocp29
  ipv4: 65.109.148.172
  ipv6: 2a01:4f9:3100:4b02::/64
  netplan:
    template: custom
    configuration: |
      network:
        version: 2
        renderer: networkd
        ethernets:
          enp6s0:
            addresses:
              - 65.109.148.172/32
              - 2a01:4f9:3100:4b02::2/64
            routes:
              - on-link: true
                to: 0.0.0.0/0
                via: 65.109.148.129
              - to: default
                via: fe80::1
            nameservers:
              addresses:
                - 185.12.64.1
                - 2a01:4ff:ff00::add:1
                - 185.12.64.2
                - 2a01:4ff:ff00::add:2
                - 1.1.1.1
                - 2606:4700:4700::1111
                - 208.67.222.222
                - 2620:119:35::35

vm:
  # https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES
  nr_hugepages: 4300
  # For Redis service in spoonbill.yaml.
  overcommit_memory: 1

ntp:
  - 0.fi.pool.ntp.org
  - 1.fi.pool.ntp.org
  - 2.fi.pool.ntp.org
  - 3.fi.pool.ntp.org

prometheus:
  node_exporter:
    smartmon: True

apache:
  public_access: True
  modules:
    mod_autoindex:
      enabled: True  # deployment is failing, otherwise
  sites:
    kingfisher-collect:
      configuration: proxy
      servername: collect.data.open-contracting.org
      context:
        documentroot: /home/collect/scrapyd
        proxypass: http://localhost:6800/
        authname: Kingfisher Scrapyd
    registry:
      configuration: django
      servername: data.open-contracting.org
      context:
        port: 8002
        static_port: 8003
        timeout: 300
    spoonbill:
      configuration: spoonbill
      servername: flatten.open-contracting.org
      context:
        port: 8005
        static_port: 8006
        timeout: 300
    rabbitmq:
      configuration: rabbitmq
      servername: rabbitmq.data.open-contracting.org
  customization: |
    <IfModule mod_rewrite.c>
      <Location "/">
        RewriteEngine On
        RewriteCond %{HTTP_USER_AGENT} "^Sogou web spider" [NC]
        RewriteRule .* - [F,L]
      </Location>
    </IfModule>

postgres:
  version: 16
  # Public access allows Docker connections. Hetzner's firewall prevents non-local connections.
  public_access: True
  data_directory: '/data/storage/postgresql/16/main'
  configuration:
    name: registry
    source: shared
    context:
      # We need a lot of connections for all the workers and threads.
      max_connections: 300  # oltp at https://pgtune.leopard.in.ua
      storage: hdd
      type: oltp
      content: |
        data_directory = '/data/storage/postgresql/16/main'

        # Avoid "checkpoints are occurring too frequently" due to intense writes (default 1GB).
        max_wal_size = 10GB
  backup:
    type: script
    location: ocp-registry-backup/database
    databases:
      - data_registry
      - spoonbill_web

docker:
  user: deployer
  uid: 1002
  syslog_logging: True

kingfisher_collect:
  user: collect
  group: deployer
  context:
    max_proc: 10
    bind_address: 0.0.0.0
    jobs_to_keep: 3
  env:
    FILES_STORE: /data/storage/kingfisher-collect
    RABBIT_EXCHANGE_NAME: &KINGFISHER_PROCESS_RABBIT_EXCHANGE_NAME kingfisher_process_data_registry_production
    # Need to sync as `{RABBIT_EXCHANGE_NAME}_api`.
    RABBIT_ROUTING_KEY: kingfisher_process_data_registry_production_api
    # Need to sync with `docker_apps.kingfisher_process.port`.
    KINGFISHER_API2_URL: http://localhost:8000
    # ecuador_sercop_bulk: Connection timed out.
    #   curl 'https://datosabiertos.compraspublicas.gob.ec/PLATAFORMA/download?type=json&year=2025&month=07&method=all'
    # chile_compra_api_*: Connection timed out.
    #   curl https://api.mercadopublico.cl/APISOCDS/OCDS/listaOCDSAgnoMesConvenio/2020/01
    # paraguay_dncp_*: Connection error.
    #   curl https://contrataciones.gov.py/datos/api/v3/doc/oauth/token
    #
    # Cloudflare issues
    # https://developers.cloudflare.com/support/troubleshooting/cloudflare-errors/troubleshooting-cloudflare-5xx-errors/
    #
    # honduras_iaip: Cloudflare responds with HTTP 522.
    #   curl 'https://www.contratacionesabiertas.gob.hn/api/v1/iaip_datosabiertos/?format=json'
    # canada_montreal: Cloudflare responded with HTTP 520, previously.
    #   curl https://ville.montreal.qc.ca/vuesurlescontrats/api/releases.json
    PROXY_SPIDERS: chile_compra_api_records,chile_compra_api_releases,ecuador_sercop_bulk,honduras_iaip,paraguay_dncp_records,paraguay_dncp_releases

docker_apps:
  registry:
    target: data-registry
    site: registry
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: data.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      FATHOM_ANALYTICS_ID: HTTGFPYH
      GUNICORN_CMD_ARGS: --workers 4
      FEEDBACK_EMAIL: jmckinney@open-contracting.org
      RABBIT_EXCHANGE_NAME: data_registry_production
      # Need to sync with `docker_apps.kingfisher_process.port`.
      KINGFISHER_PROCESS_URL: http://host.docker.internal:8000
      SCRAPYD_URL: http://host.docker.internal:6800
      SPOONBILL_URL: https://flatten.open-contracting.org
      # The path must match the settings.DATAREGISTRY_MEDIA_ROOT default value in spoonbill-web.
      SPOONBILL_EXPORTER_DIR: /data/exporter
  kingfisher_process:
    target: kingfisher-process
    port: 8000
    env:
      LOCAL_ACCESS: True
      ALLOWED_HOSTS: '*'
      RABBIT_EXCHANGE_NAME: *KINGFISHER_PROCESS_RABBIT_EXCHANGE_NAME
      # This is set to be the same size as the prefetch_count argument.
      # https://ocdsextensionregistry.readthedocs.io/en/latest/changelog.html
      REQUESTS_POOL_MAXSIZE: 20
  spoonbill:
    target: spoonbill
    site: spoonbill
    host_dir: /data/storage/spoonbill
    volumes:
      - media
      - tmp
      - redis/data
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: flatten.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      CORS_ALLOWED_ORIGINS: https://flatten.open-contracting.org

# The registry app writes to this directory. The spoonbill app reads from this directory.
exporter_host_dir: /data/storage/exporter

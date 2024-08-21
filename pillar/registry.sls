network:
  host_id: ocp27
  ipv4: 37.27.62.45
  ipv6: 2a01:4f9:3081:3001::/64
  netplan:
    template: custom
    configuration: |
      network:
        version: 2
        renderer: networkd
        ethernets:
          enp5s0:
            addresses:
              - 37.27.62.45/32
              - 2a01:4f9:3081:3001::2/64
            routes:
              - on-link: true
                to: 0.0.0.0/0
                via: 37.27.62.1
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
  nr_hugepages: 8231

ntp:
  - 0.fi.pool.ntp.org
  - 1.fi.pool.ntp.org
  - 2.fi.pool.ntp.org
  - 3.fi.pool.ntp.org

prometheus:
  node_exporter:
    smartmon: True

rsyslog:
  conf:
    80-docker.conf: docker.conf

logrotate:
  conf:
    docker:
      source: docker

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
      configuration: registry
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
      - spoonbill_web
      - pelican_frontend

docker:
  user: deployer
  uid: 1002
  syslog_logging: True

python:
  version: '3.10'

kingfisher_collect:
  user: collect
  group: deployer
  context:
    bind_address: 0.0.0.0
    jobs_to_keep: 8
  env:
    FILES_STORE: /data/storage/kingfisher-collect
    RABBIT_EXCHANGE_NAME: &KINGFISHER_PROCESS_RABBIT_EXCHANGE_NAME kingfisher_process_data_registry_production
    # Need to sync as `{RABBIT_EXCHANGE_NAME}_api`.
    RABBIT_ROUTING_KEY: kingfisher_process_data_registry_production_api
    # Need to sync with `docker_apps.kingfisher_process.port`.
    KINGFISHER_API2_URL: http://localhost:8000

docker_apps:
  registry:
    target: data-registry
    exporter_host_dir: /data/storage/exporter_dumps
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: data.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      FATHOM_ANALYTICS_ID: HTTGFPYH
      FEEDBACK_EMAIL: jmckinney@open-contracting.org
      RABBIT_EXCHANGE_NAME: data_registry_production
      # Need to sync with `docker_apps.kingfisher_process.port`.
      KINGFISHER_PROCESS_URL: http://host.docker.internal:8000
      # Need to sync with `docker_apps.pelican_frontend.port`.
      PELICAN_FRONTEND_URL: http://host.docker.internal:8001
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
  pelican_backend:
    target: pelican-backend
    env:
      RABBIT_EXCHANGE_NAME: &PELICAN_BACKEND_RABBIT_EXCHANGE_NAME pelican_backend_data_registry_production
      # 2021-10-27: on kingfisher-main, out of 6.12318e+07 data items, 195009 or 0.3% are over 30 kB.
      KINGFISHER_PROCESS_MAX_SIZE: 30000
      PELICAN_BACKEND_STEPS: field_coverage
  pelican_frontend:
    target: pelican-frontend
    port: 8001
    host_dir: /data/storage/pelican-frontend
    env:
      LOCAL_ACCESS: True
      ALLOWED_HOSTS: '*'
      RABBIT_EXCHANGE_NAME: *PELICAN_BACKEND_RABBIT_EXCHANGE_NAME
      # Avoid warning: "Matplotlib created a temporary config/cache directory at /.config/matplotlib because the
      # default path (/tmp/matplotlib-........) is not a writable directory; it is highly recommended to set the
      # MPLCONFIGDIR environment variable to a writable directory, in particular to speed up the import of Matplotlib
      # and to better support multiprocessing."
      MPLCONFIGDIR: /dev/shm/matplotlib
  spoonbill:
    target: spoonbill
    host_dir: /data/storage/spoonbill
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: flatten.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      CORS_ALLOWED_ORIGINS: https://flatten.open-contracting.org

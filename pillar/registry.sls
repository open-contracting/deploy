ssh:
  root:
    # Datlab
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8CBXEfTLXq/COZawwvCgmNJSrLOvR6oolQXDCg45p1w/AX9pavtAxqDzxxPBL8JZSTO8/5N1/PPxVLCIk6+QquCCVsEACaGWUu8vB+rPfyoYh00vI1QiLtFG38J3gJDbq+FRJ9ch4OQ8kJeQPqenKVe2zvMJUzFFkr2fi0aPuxwWM8jzeY0bRbs2CxdZ5z8zoN1Tm49p/htk+6w4dkrwtPpersia8f3o9fbdOrGm4zXTEE3hjuZa5fdC3pRdpKJ5iikf0yKziEoYT/YtPfbAsfSOtRMz5vd4MM9j4cOU3IPKPLrvk8vDCePQLpOl6jKN9JMLGJDEDkoLjTt/A29b/xyP/oO+9NY4j8kQFxEW5xw1Pd+NEKNBh9aSi3hHWA9rSQqxHaL22V4czWpfAcyQmJOtXNCK/2ISQiZK5vk3Ja6JSv+07hwE1Mr4yR1MvIaaIiVq/LvovYIsObHlkbw5F+Ov5ewuyJ/nXU16v2GQKiUwvotX7O4F6JhxWSUd/WOuxOoiT9q0H2cwskUof29ESFE/8/unHaxPSnYTkTalDVu9zLFj8RtxJhUz5k1xcjO2zT7BZWcDG6XGshLnTu21WbROlNBaIBASHNhmZ0MMAaF8Gc3A4R69ytuFliPG0VRScU1GuCW6BRz4oR5ym4rJUZIEUk4azdSJZ21CKFUheDQ== Jakub (Datlab)
    # Quintagroup
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiQnzGUHtsokFSkivn6AAYJEqPBaL/bgtlDzYAVtWQv Myroslav (Quintagroup)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmf4aYcVVs8M6/jYpoJbZ0MDSodLZDmJDSx6wDbLOrzD4xxLP52hMHaMA3hlgwdu3mQPYBH8tTJ5It9HfgHgfGChOKho0cLIxumfi6gpHwly6AkX9LdeuPS6B+dpNn1REl4+mh3XzrxhiDp3nhwCNQFq6EWi3OdLDY+fZ7F4rRAiqIGJfFRRnLOTZ/UazTK/V6Qhy/Hsax7DgcuGMrVQCIy76zESvjthPj7iS5m+vZrNtUnKe6a0xKIcOMCU0xmR4u9++OoYCXl5UhpkT3h4YcuEFds70UznmRB+DElW9LaUGxDDyP3rTbHjwQRHS1sD21Y6ggN5LvLr7WDnBJGxTS1kCKSavM3EARvRhrP/VHZSaNscs0sR0BK5wLbBhunnZ+IWiU9YJ2oQApJg93ARvvAf1FIvlvnfwf/NqvcNjNoqv5AY5eKHI5fUWoVKA+vC6kqFM49DulrDDDSVYlE3WJHUMKst7lz2GJk6kT8R/upjPrficF02cJULMdAJjBWIE= Anton Shakh (Quintagroup)

vm:
  nr_hugepages: 8231

prometheus:
  node_exporter:
    smartmon: True

apache:
  public_access: True
  ipv4: 65.21.93.181
  ipv6: 2a01:4f9:3b:45ca::2
  sites:
    # Can use Scrapyd's basic authentication instead once 1.3 is released.
    # https://github.com/scrapy/scrapyd/issues/364
    # https://pypi.org/project/scrapyd/#history
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
        # Need to sync with `docker_apps.registry.port`.
        port: 8002
        static_port: 8003
        timeout: 300

postgres:
  # Public access allows Docker connections. Hetzner's firewall prevents non-local connections.
  public_access: true
  version: 12
  configuration: registry
  storage: hdd
  type: oltp
  # We need a lot of connections for all the workers and threads.
  max_connections: 300  # oltp at https://pgtune.leopard.in.ua

docker:
  user: deployer
  uid: 1002
  docker_compose:
    version: 1.29.2

kingfisher_collect:
  user: collect
  group: deployer
  context:
    bind_address: 0.0.0.0
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
    port: 8002
    exporter_host_dir: /data/storage/exporter_dumps
    env:
      ALLOWED_HOSTS: data.open-contracting.org
      DJANGO_PROXY: True
      FATHOM_ANALYTICS_ID: HTTGFPYH
      FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
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
  pelican_backend:
    target: pelican-backend
    env:
      RABBIT_EXCHANGE_NAME: &PELICAN_BACKEND_RABBIT_EXCHANGE_NAME pelican_backend_data_registry_production
      # 2021-10-27: on kingfisher-process, out of 6.12318e+07 data items, 195009 or 0.3% are over 30 kB.
      KINGFISHER_PROCESS_MAX_SIZE: 30000
      PELICAN_BACKEND_STEPS: field_coverage
  pelican_frontend:
    target: pelican-frontend
    port: 8001
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
    base_host_dir: /data/storage/spoonbill
    env:
      TRAEFIK_IP: 65.21.93.141
      DOMAIN: &DOMAIN flatten.open-contracting.org
      API_DOMAIN: *DOMAIN
      ALLOWED_HOSTS: *DOMAIN
      DJANGO_ENV: production
      CORS_ORIGIN_WHITELIST: https://flatten.open-contracting.org
      API_PREFIX: api/
      DB_HOST: postgres
      REDIS_HOST: redis

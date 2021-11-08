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
        port: 8002
        static_port: 8003

postgres:
  version: 12
  configuration: registry
  storage: hdd
  type: oltp
  # We can monitor the number of connections with all workers and web servers running, to see if the default can be restored.
  max_connections: 200

docker:
  user: deployer
  docker_compose:
    version: 1.29.2

kingfisher_collect:
  user: collect
  env:
    FILES_STORE: &SCRAPY_FILES_STORE /data/storage/kingfisher-collect
    KINGFISHER_API2_URL: http://localhost:8000
    # This needs to correspond to ENV_NAME and ENV_VERSION below.
    RABBIT_EXCHANGE_NAME: kingfisher_process_data_registry_1.0
    RABBIT_QUEUE_NAME: kingfisher_process_data_registry_1.0_api_loader
    RABBIT_ROUTING_KEY: kingfisher_process_data_registry_1.0_api

docker_apps:
  registry:
    target: data-registry
    port: 8002
    env:
      FEEDBACK_EMAIL: jmckinney@open-contracting.org
      FATHOM_ANALYTICS_ID: HTTGFPYH
      FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
      RABBIT_EXCHANGE_NAME: data_registry_production
      PROCESS_HOST: http://localhost:8000/
      PELICAN_HOST: http://localhost:8001/
      EXPORTER_HOST: http://localhost:8002/
      # Kingfisher Collect
      SCRAPY_HOST: http://localhost:6800/
      SCRAPY_PROJECT: kingfisher
      # Spoonbill
      FLATTEN_URL: https://flatten.open-contracting.org
  kingfisher_process:
    target: kingfisher-process
    port: 8000
    env:
      # Kingfisher Process uses a Rabbit exchange named `kingfisher_process_{ENV_NAME}_{ENV_VERSION}`.
      # Remember to update `RABBIT_EXCHANGE_NAME` and `RABBIT_ROUTING_KEY` above.
      ENV_NAME: data_registry
      ENV_VERSION: '1.0'
  pelican_backend:
    target: pelican-backend
    env:
      DATABASE_SCHEMA: production,public
      RABBIT_EXCHANGE_NAME: &PELICAN_RABBIT_EXCHANGE_NAME pelican_data_registry_production
      LOG_FILENAME: /data/storage/logs/pelican-backend.log
      # SENTRY_SAMPLE_RATE: 1
  pelican_frontend:
    target: pelican-frontend
    port: 8001
    env:
      RABBIT_EXCHANGE_NAME: *PELICAN_RABBIT_EXCHANGE_NAME
      # Temporary fix
      RABBIT_HOST: localhost
      RABBIT_PORT: 5672

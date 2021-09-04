x-variables:
  # This needs to correspond to `docker_apps.kingfisher_process.port`.
  KINGFISHER_PROCESS_URL: &KINGFISHER_PROCESS_URL http://localhost:8000
  SCRAPY_FILES_STORE: &SCRAPY_FILES_STORE /data/storage/kingfisher-collect
  PELICAN_RABBIT_EXCHANGE_NAME: &PELICAN_RABBIT_EXCHANGE_NAME dqt_data_registry_production

ssh:
  root:
    # Datlab
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8CBXEfTLXq/COZawwvCgmNJSrLOvR6oolQXDCg45p1w/AX9pavtAxqDzxxPBL8JZSTO8/5N1/PPxVLCIk6+QquCCVsEACaGWUu8vB+rPfyoYh00vI1QiLtFG38J3gJDbq+FRJ9ch4OQ8kJeQPqenKVe2zvMJUzFFkr2fi0aPuxwWM8jzeY0bRbs2CxdZ5z8zoN1Tm49p/htk+6w4dkrwtPpersia8f3o9fbdOrGm4zXTEE3hjuZa5fdC3pRdpKJ5iikf0yKziEoYT/YtPfbAsfSOtRMz5vd4MM9j4cOU3IPKPLrvk8vDCePQLpOl6jKN9JMLGJDEDkoLjTt/A29b/xyP/oO+9NY4j8kQFxEW5xw1Pd+NEKNBh9aSi3hHWA9rSQqxHaL22V4czWpfAcyQmJOtXNCK/2ISQiZK5vk3Ja6JSv+07hwE1Mr4yR1MvIaaIiVq/LvovYIsObHlkbw5F+Ov5ewuyJ/nXU16v2GQKiUwvotX7O4F6JhxWSUd/WOuxOoiT9q0H2cwskUof29ESFE/8/unHaxPSnYTkTalDVu9zLFj8RtxJhUz5k1xcjO2zT7BZWcDG6XGshLnTu21WbROlNBaIBASHNhmZ0MMAaF8Gc3A4R69ytuFliPG0VRScU1GuCW6BRz4oR5ym4rJUZIEUk4azdSJZ21CKFUheDQ== Jakub (Datlab)
    # Quintagroup
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiQnzGUHtsokFSkivn6AAYJEqPBaL/bgtlDzYAVtWQv Myroslav (Quintagroup)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmf4aYcVVs8M6/jYpoJbZ0MDSodLZDmJDSx6wDbLOrzD4xxLP52hMHaMA3hlgwdu3mQPYBH8tTJ5It9HfgHgfGChOKho0cLIxumfi6gpHwly6AkX9LdeuPS6B+dpNn1REl4+mh3XzrxhiDp3nhwCNQFq6EWi3OdLDY+fZ7F4rRAiqIGJfFRRnLOTZ/UazTK/V6Qhy/Hsax7DgcuGMrVQCIy76zESvjthPj7iS5m+vZrNtUnKe6a0xKIcOMCU0xmR4u9++OoYCXl5UhpkT3h4YcuEFds70UznmRB+DElW9LaUGxDDyP3rTbHjwQRHS1sD21Y6ggN5LvLr7WDnBJGxTS1kCKSavM3EARvRhrP/VHZSaNscs0sR0BK5wLbBhunnZ+IWiU9YJ2oQApJg93ARvvAf1FIvlvnfwf/NqvcNjNoqv5AY5eKHI5fUWoVKA+vC6kqFM49DulrDDDSVYlE3WJHUMKst7lz2GJk6kT8R/upjPrficF02cJULMdAJjBWIE= Anton Shakh (Quintagroup)

prometheus:
  node_exporter:
    smartmon: True

docker:
  docker_compose:
    version: 1.29.2

docker_apps:
  registry:
    target: data-registry
    port: 8002
    env:
      ENVIRONMENT: production
      FEEDBACK_EMAIL: jmckinney@open-contracting.org
      FATHOM_ANALYTICS_ID: HTTGFPYH
      FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
      RABBIT_EXCHANGE_NAME: data_registry_production
      EXPORTER_DIR: /data/storage/exporter_dumps
      # This needs to correspond to `docker_apps.kingfisher_process.port`.
      PROCESS_HOST: http://localhost:8000/
      # This needs to correspond to `docker_apps.pelican_frontend.port`.
      PELICAN_HOST: http://localhost:8001/
      # This needs to correspond to `docker_apps.registry.port`.
      EXPORTER_HOST: http://localhost:8002/
      # Kingfisher Collect
      SCRAPY_HOST: http://localhost:6800/
      SCRAPY_PROJECT: kingfisher
      SCRAPY_FILES_STORE: *SCRAPY_FILES_STORE
      # Spoonbill
      FLATTEN_URL: https://flatten.open-contracting.org

  kingfisher_collect:
    target: kingfisher-collect
    env:
      FILES_STORE: *SCRAPY_FILES_STORE
      KINGFISHER_API2_URL: *KINGFISHER_PROCESS_URL
      # This needs to correspond to ENV_NAME and ENV_VERSION below.
      RABBIT_EXCHANGE_NAME: kingfisher_process_data_registry_1.0
      RABBIT_ROUTING_KEY: kingfisher_process_data_registry_1.0_api

  kingfisher_process:
    target: kingfisher-process
    # Remember to update KINGFISHER_PROCESS_URL above.
    port: 8000
    env:
      # Kingfisher Process uses a Rabbit exchange named `kingfisher_process_{ENV_NAME}_{ENV_VERSION}`.
      # Remember to update RABBIT_EXCHANGE_NAME and RABBIT_ROUTING_KEY above.
      ENV_NAME: data_registry
      ENV_VERSION: '1.0'

  pelican_backend:
    target: dqt
    env:
      DATABASE_SCHEMA: production,public
      RABBIT_EXCHANGE_NAME: *PELICAN_RABBIT_EXCHANGE_NAME
      LOG_FILENAME: /data/storage/logs/dqt.log

  pelican_frontend:
    target: dqv
    port: 8001
    env:
      RABBIT_EXCHANGE_NAME: *PELICAN_RABBIT_EXCHANGE_NAME
      TOKEN_PATH: /data/dqv/token.pickle
      SENTRY_SAMPLE_RATE: 1

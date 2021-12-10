docker:
  user: deployer
  uid: 1002
  docker_compose:
    version: 1.29.2

docker_apps:
  spoonbill:
    target: spoonbill
    env:
      DOMAIN: &DOMAIN flatten.open-contracting.org
      API_DOMAIN: *DOMAIN
      TRAEFIK_IP: 65.21.93.141
      ACME_EMAIL: shakh@quintagroup.org
      DEBUG: 1
      DJANGO_ALLOWED_HOSTS: *DOMAIN
      ALLOWED_HOSTS: *DOMAIN
      DB_HOST: postgres
      REDIS_HOST: redis
      CORS_ORIGIN_WHITELIST: https://flatten.open-contracting.org
      SENTRY_ENVIRONMENT: prod
      API_PREFIX: api/

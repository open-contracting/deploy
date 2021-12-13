docker_apps:
  spoonbill:
    target: spoonbill
    env:
      DOMAIN: &DOMAIN flatten.open-contracting.org
      API_DOMAIN: *DOMAIN
      TRAEFIK_IP: 65.21.93.141
      ACME_EMAIL: shakh@quintagroup.org
      DJANGO_ALLOWED_HOSTS: *DOMAIN
      DB_HOST: postgres
      REDIS_HOST: redis
      CORS_ORIGIN_WHITELIST: https://flatten.open-contracting.org
      API_PREFIX: api/

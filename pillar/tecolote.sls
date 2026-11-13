apache:
  sites:
    tecolote:
      configuration: proxy
      servername: tecolote.open-contracting.org
      context:
        proxypass: http://localhost:8004/
        authname: Tecolote

docker_apps:
  tecolote:
    target: tecolote
    port: 8004
    volumes:
      - data
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: tecolote.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      RRAP_AI_SETTINGS: /pemex-rrap-ai/settings/haiku.toml
      RETENTION_DAYS: 30

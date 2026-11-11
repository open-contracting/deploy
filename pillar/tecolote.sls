apache:
  sites:
    tecolote:
      configuration: proxy
      servername: tecolote.open-contracting.org
      context:
        port: 8004
        proxypass: http://localhost:8004/ timeout=300
        authname: Tecolote

docker_apps:
  tecolote:
    target: tecolote
    site: tecolote
    volumes:
      - data
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: tecolote.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      RRAP_AI_SETTINGS: settings/haiku.toml
      RETENTION_DAYS: 30

apache:
  sites:
    digitalbuying:
      configuration: django
      servername: digitalbuying.open-contracting.org
      context:
        port: 8000
        static_port: 8001
        timeout: 300

mysql:
  databases:
    digitalbuying:
      user: digitalbuying

docker_apps:
  digitalbuying:
    target: digitalbuying
    site: digitalbuying
    volumes:
      - media
      - redis/data
      - redis/tmp
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: digitalbuying.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      FATHOM_ANALYTICS_ID: WEGZFMFJ
      REDIS_URL: redis://redis:6379/0

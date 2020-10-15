include:
  - django

{% from 'django.sls' import djangodir %}

# See https://cove.readthedocs.io/en/latest/deployment/

remoteip:
  apache_module.enabled:
    - name: remoteip
    - watch_in:
      - service: apache2

cd {{ djangodir }}; . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ pillar.django.app }}.settings SECRET_KEY="{{ pillar.django.env.SECRET_KEY|replace('%', '\%') }}" python manage.py expire_files:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: cove
    - minute: random
    - hour: 0

MAILTO:
  cron.env_present:
    - name: MAILTO
    - value: sysadmin@open-contracting.org
    - user: cove

memcached_server:
  pkg.installed:
    - pkgs:
     - memcached

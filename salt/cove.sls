include:
  - django
  - apache.modules.remoteip

root_cove:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_cove

{% from 'django.sls' import djangodir %}

# See https://cove.readthedocs.io/en/latest/deployment/

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

memcached:
  pkg.installed:
    - name: memcached
  service.running:
    - name: memcached
    - enable: True

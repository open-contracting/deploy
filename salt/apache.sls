{% from 'lib.sls' import apache %}

apache2:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - reload: True

# Use the system default locale for Apache
# This affects how python behaves under mod_wsgi
# see https://code.djangoproject.com/wiki/django_apache_and_mod_wsgi#AdditionalTweaking
/etc/apache2/envvars:
  file.uncomment:
    # Note due to https://github.com/saltstack/salt/issues/24907 you may need to apply this change manually.
    - regex: \. /etc/default/locale
    - require:
      - pkg: apache2

# This file is not served unless explicitly aliased from an Apache configuration file.
/var/www/html/robots.txt:
  file.managed:
    - source: salt://apache/robots_dev.txt

# Ensure 000-default conf exists, so it's obvious when we've typo'd something
{{ apache('000-default.conf') }}

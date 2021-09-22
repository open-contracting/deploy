# The default locale is en_GB rather than en_US for accidental, historical reasons.
en_gb_locale:
  locale.present:
    - name: en_GB.UTF-8

system_locale:
  locale.system:
    - name: en_GB.UTF-8
    - require:
      - locale: en_gb_locale

# To avoid error when running "pip-sync -q".
# https://click.palletsprojects.com/en/7.x/python3/
/etc/default/locale:
  file.keyvalue:
    - key: LC_ALL
    - value: '"en_GB.UTF-8"'
    - append_if_not_found: True

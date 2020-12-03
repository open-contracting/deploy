en_gb_locale:
  locale.present:
    - name: en_GB.UTF-8

default_locale:
  locale.system:
    - name: en_GB.UTF-8
    - require:
      - locale: en_gb_locale

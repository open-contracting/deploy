{{ pillar.locale }}_locale:
  locale.present:
    - name: {{ pillar.locale }}.UTF-8

system_locale:
  locale.system:
    - name: {{ pillar.locale }}.UTF-8
    - require:
      - locale: {{ pillar.locale }}_locale

# https://click.palletsprojects.com/en/latest/unicode-support/#surrogate-handling
/etc/default/locale:
  file.keyvalue:
    - key: LC_ALL
    - value: '"{{ pillar.locale }}.UTF-8"'
    - append_if_not_found: True

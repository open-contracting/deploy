add_system_locale_en_gb_utf8:
  file.replace:
    - name:  /etc/locale.gen
    - pattern: "[# ]*en_GB.UTF-8 UTF-8"
    - repl: "en_GB.UTF-8 UTF-8"
    - append_if_not_found: True

run_locale_gen:
  cmd.run:
    - name: locale-gen
    - onchanges:
      - file: add_system_locale_en_gb_utf8

set_lc_all:
  file.append:
    - text: 'LC_ALL="en_GB.UTF-8"'
    - name: /etc/default/locale

add_system_locale_en_gb_utf8:
  # This line may be in the file but commented out.
  # However we use file.append here instead of file.replace because we can't guarantee each Linux Distro build will comment out the lines in the same way.
  # Could use replace with "- append_if_not_found: True"
  file.append:
    - name:  /etc/locale.gen
    - text: "en_GB.UTF-8 UTF-8"

run_locale_gen:
  cmd.run:
    - name: locale-gen
    - onchanges:
      - file: add_system_locale_en_gb_utf8

set_lc_all:
  file.append:
    - text: 'LC_ALL="en_GB.UTF-8"'
    - name: /etc/default/locale

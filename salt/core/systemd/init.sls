# Stop RemoveIPC killing all processes by a user when they log out.
{% if grains['osrelease']|float >= 20.04 %}
/etc/systemd/logind.conf.d/customization.conf:
  file.managed:
    - source: salt://core/systemd/files/logind.conf
    - makedirs: True
    - watch_in:
      - service: systemd-logind

{% else %}
/etc/systemd/logind.conf:
  file.replace:
    - pattern: "#?RemoveIPC=yes"
    - repl: "RemoveIPC=no"
    - append_if_not_found: True
{% endif %}

systemd-logind:
  service.running:
    - name: systemd-logind

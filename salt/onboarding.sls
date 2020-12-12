# Expects an additional argument defining the server hostname. Example:
#
#   salt-ssh 'example' state.apply 'onboarding,core*' pillar='{"host_id":"ocpXX"}'
#
# `order` is used, to ensure these states run before any core states.

update all packages:
  pkg.uptodate:
    - order: 1
    - refresh: True
    - dist_upgrade: True

/etc/hosts:
  file.append:
    - order: 2
    - text: |
{%- if 'fqdn_ip4' in grains %}
        {{ grains.fqdn_ip4[0] }} {{ pillar.host_id }} {{ pillar.host_id }}.open-contracting.org
{%- endif %}
{%- if 'fqdn_ip6' in grains %}
        {{ grains.fqdn_ip6[0] }} {{ pillar.host_id }} {{ pillar.host_id }}.open-contracting.org 
{%- endif %}

/etc/mailname:
  file.managed:
    - order: 3
    - contents: "{{ pillar.host_id }}.open-contracting.org"

/etc/hostname:
  file.managed:
    - order: 4
    - contents: "{{ pillar.host_id }}"

hostname -F /etc/hostname:
  cmd.run:
    - order: 5
    - onchanges:
      - file: /etc/hostname

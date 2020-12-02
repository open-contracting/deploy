# Salt script for onboarding new servers.
#
# The below salt states are ordered to ensure they are executed before the other core install states.
#
# Expects an additional argument defining the server hostname.
# Example:  salt-ssh 'example' state.apply onboarding pillar='{"host_id":"ocpXX"}'

Update all packages:
  pkg.uptodate:
    - refresh: True
    - dist_upgrade: True
    - order: 1

/etc/hosts:
  file.append:
    - order: 2
    - text: |
{%- if grains['fqdn_ip4'] is defined %}
        {{ grains['fqdn_ip4'][0] }} {{ pillar['host_id'] }} {{ pillar['host_id'] }}.open-contracting.org
{%- endif %}
{%- if grains['fqdn_ip6'] is defined %}
        {{ grains['fqdn_ip6'][0] }} {{ pillar['host_id'] }} {{ pillar['host_id'] }}.open-contracting.org 
{%- endif %}

/etc/mailname:
  file.managed:
    - contents: "{{ pillar['host_id'] }}.open-contracting.org"
    - order: 3

/etc/hostname:
  file.managed:
    - contents: {{ pillar['host_id'] }}
    - order: 3

hostname -F /etc/hostname:
  cmd.run:
    - onchanges:
      - file: /etc/hostname
    - order: 4

include:
  - core


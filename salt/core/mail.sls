# Install and configure email software.
postfix:
  pkg.installed:
    - name: postfix
    - require:
      - debconf: postfix
  service.running:
    - name: postfix
    - enable: True
    - require:
      - pkg: postfix
  debconf.set:
    - data:
        # I don't expect FQDN to ever be unset but if it is, fallback to /etc/mailname.
        'postfix/mailname': {'type': 'string', 'value': {{ salt['grains.get']('fqdn', '/etc/mailname') }} }
        # "Internet Site" means mail is sent and received directly using SMTP.
        'postfix/main_mailer_type': { 'type' : 'select', 'value' : 'Internet Site' }
    - require:
      - pkg: debconf-utils
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive postfix
    - require:
      - pkg: postfix
    - onchanges:
      - debconf: postfix
  file.keyvalue:
    - name: /etc/postfix/main.cf
    - key_values:
        # On first run, myhostname may default to previous ISP value.
        myhostname: "{{ pillar.network.host_id }}.{{ pillar.network.domain }}"
{%- if pillar.smtp.relay %}
        relayhost: "[{{ pillar.smtp.host }}]:{{ pillar.smtp.port }}"
        smtp_sasl_auth_enable: "yes"
        smtp_sasl_security_options: "noanonymous"
        smtp_sasl_password_maps: "hash:/etc/postfix/sasl_passwd"
        smtp_use_tls: "yes"
        smtp_tls_note_starttls_offer: "yes"
{%- if "relay_address" in pillar.smtp %}
        smtp_generic_maps: "hash:/etc/postfix/generic"
        smtp_header_checks: "regexp:/etc/postfix/smtp_header_checks"
{%- endif %}
{%- endif %}
    - separator: ' = '
    - append_if_not_found: True
    - watch_in:
      - service: postfix

{%- if pillar.smtp.relay %}
/etc/postfix/sasl_passwd:
  file.managed:
    - contents: "[{{ pillar.smtp.host }}]:{{ pillar.smtp.port }} {{ pillar.smtp.username }}:{{ pillar.smtp.password }}"
    - mode: 600
  cmd.run:
    - name: postmap hash:/etc/postfix/sasl_passwd
    - require:
      - pkg: postfix
    - onchanges:
      - file: /etc/postfix/sasl_passwd
    - watch_in:
      - file: postfix
{% endif %}

{%- if "relay_address" in pillar.smtp %}
/etc/postfix/generic:
  file.managed:
    - contents: "@{{ pillar.network.host_id }}.{{ pillar.network.domain }}        {{ pillar.smtp.relay_address }}"
    - mode: 600
  cmd.run:
    - name: postmap hash:/etc/postfix/generic
    - require:
      - pkg: postfix
    - onchanges:
      - file: /etc/postfix/generic
    - watch_in:
      - file: postfix

/etc/postfix/smtp_header_checks:
  file.managed:
    # Whitespace is optional after "From:". Ignore display name.
    - contents: >
        /^From:[[:space:]]*(.*<)?root@{{ pillar.network.host_id }}\.{{ pillar.network.domain|regex_escape }}>?/
        REPLACE From: root@{{ pillar.network.host_id }} <{{ pillar.smtp.relay_address }}>
    - mode: 600
    - watch_in:
      - service: postfix
{% endif %}

# Install commands for users to interact with mail.
mailutils:
  pkg.installed:
    - name: mailutils

# Configure /etc/aliases.
root:
  alias.present:
    - target: {{ pillar.system_contacts.root }}
admin:
  alias.present:
    - target: root
postmaster:
  alias.present:
    - target: root

# Set up root crontab email.
set MAILTO environment variable in root crontab:
  cron.env_present:
    - name: MAILTO
    - value: {{ pillar.system_contacts.cron_admin }}
    - user: root

# We'll only be using SSH key authentication.
{% if grains['osrelease'] >= '20.04' %}
/etc/ssh/sshd_config.d/customization.conf:
  file.managed:
    - source: salt://core/sshd/files/customization.conf
    - watch_in:
      - service: ssh_service

{% else %}
# We set both PermitRootLogin and PasswordAuthentication for two reasons:
#
# - PermitRootLogin adds a layer of security in case PasswordAuthentication is toggled on.
# - While PermitRootLogin is set to "no" or "without-password", we can monitor it with our intrusion detection software.
harden ssh configuration:
  file.keyvalue:
    - name: /etc/ssh/sshd_config
    - key_values:
        # Disable password authentication.
        PasswordAuthentication: 'no'
        # Force root logins with SSH keys.
        PermitRootLogin: without-password
        # Disable X11 forwarding.
        X11Forwarding: 'no'
    - separator: ' '
    - uncomment: '# '
    - key_ignore_case: True
    - append_if_not_found: True
    - watch_in:
      - service: ssh_service
{% endif %}

# Restart the SSH service if the config changes.
ssh_service:
  service.running:
    - name: ssh
    - enable: True
    - reload: True

# Manage authorized keys for users with root access to all servers.
root_authorized_keys:
  ssh_auth.manage:
    - user: root
    - ssh_keys: {{ (pillar.ssh.admin + salt['pillar.get']('ssh:root', []))|yaml }}

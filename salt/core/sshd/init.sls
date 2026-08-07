# We'll only be using SSH key authentication.
/etc/ssh/sshd_config.d/customization.conf:
  file.managed:
    - source: salt://core/sshd/files/customization.conf
    - template: jinja
    - watch_in:
      - service: ssh_service

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

# We'll only be using SSH key authentication
disable password authentication:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^#?PasswordAuthentication .*"
    - repl: PasswordAuthentication no

# Technically not needed but setting for posterity
force root ssh keys:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^#?PermitRootLogin.*"
    - repl: "PermitRootLogin without-password"

disable x11forwarding:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: "^#?X11Forwarding yes"
    - repl: "X11Forwarding no"

# Restart the SSH service if the config changes
ssh_service:
  service.running:
    - name: ssh
    - enable: True
    - reload: True
    - listen: 
      - file: /etc/ssh/sshd_config


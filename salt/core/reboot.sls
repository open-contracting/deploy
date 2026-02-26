include:
  - core.mail

# Notify admins on boot
echo "$(hostname) rebooted at $(date -Iseconds)":
  cron.present:
    - identifier: REBOOT_NOTICIATION
    - user: root
    - special: '@reboot'
    - require:
      # Require MAILTO cron.env_present
      - sls: core.mail

# Values used on all servers. These may be overwritten.
automatic_reboot: 'false'

prometheus_node_exporter:
  enabled: true

maintenance:
  enabled: false

system_contacts:
  # Root email contact for system notifications
  root: "sysadmin@dogsbody.com"

  # Email contact for crons
  cron_admin: "sysadmin@open-contracting.org,sysadmin@dogsbody.com"

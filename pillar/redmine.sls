network:
  host_id: ocp16
  ipv4: 139.162.219.246
  ipv6: "2a01:7e00:e000:07fd::"
  netplan:
    template: linode
    gateway4: 139.162.219.1
    addresses:
      - 2a01:7e00::f03c:93ff:fe24:07b9/64 # SLAAC

backup:
  ocp-redmine-backup/site:
    # Must match directory in redmine/init.sls.
    - /home/redmine/public_html/

apache:
  public_access: True
  sites:
    crm:
      configuration: redmine
      servername: crm.open-contracting.org

mysql:
  version: '8.0'
  configuration: False
  backup:
    location: ocp-redmine-backup/database

rvm:
  default_version: 3.1.2

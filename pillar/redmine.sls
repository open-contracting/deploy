network:
  host_id: ocp16
  ipv4: 139.162.219.246
#  ipv6: 2a01:7e00::f03c:93ff:fe24:07b9
#  netplan:
#    template: linode
#    addresses:
#      - 2a01:7e00::f03c:93ff:fe24:07b9/64 # SLAAC
#    gateway4: 198.51.100.1
#    gateway6: fe80::1

apache:
  public_access: True
  sites:
    crm:
      configuration: redmine
      servername: crm.open-contracting.org

mysql:
  version: 8.0
  configuration: False
  databases:
    redmine:
      user: redmine

rvm:
  default_version: 3.1.2

redmine:
  user: redmine
  svn:
    branch: 5.0-stable
    revision: 21783
  database:
    name: redmine
    user: redmine
  plugins:
    - redmine_agile
    - redmine_checklists
    - redmine_contacts
    - redmine_contacts_helpdesk
    - view_customize

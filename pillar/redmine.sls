network:
  host_id: ocp16
  ipv4: 139.162.219.246
  ipv6: "2a01:7e00:e000:07fd::"
  netplan:
    template: linode
    addresses:
      - 2a01:7e00::f03c:93ff:fe24:07b9/64 # SLAAC
    gateway4: 139.162.219.1
    gateway6: fe80::1

apache:
  public_access: True
  sites:
    crm:
      configuration: redmine
      servername: crm.open-contracting.org

mysql:
  version: '8.0'
  configuration: False

rvm:
  default_version: 3.1.2
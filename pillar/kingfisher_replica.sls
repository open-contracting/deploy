# Allow ocp04 to access PostgreSQL backups.
firewall:
  additional_ssh_ipv4:
    - 95.217.76.74
  additional_ssh_ipv6:
    - 2a01:4f9:4a:1bd3::2

# Allow ocp04 to access PostgreSQL backups.
ssh:
  postgres:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJ6FdpCTb9AL7OXNm3XFO1db1fd2EtnXmWruTIeFjgvp7EzJidH0DdBmhjPaNLiIIgEReoHj5ibb2GYhCR1jGLGGEXhuvv/7UtFI9sbwCtlDsxMZFQSGCBNuZIHDexXKx3OwvtysTYDytwy8PbfeZwD5pOR+LvmGC8Abs95cacwMWW7D5uHU3sgbit+hS1KgDWII1EIuYztcVMvkfQeyl827pdtEzgz8tRWJLwQ9YXQbC/xXdA3AJQE6dcGBtemP4M0Hv97U2bPnROHcXlLkNGYhNoBz3AFB0Q/p0UvOPJ9T3GHHsxwrrrlow8lhJZWGnjAdbyuFRHAA3eqDPRy9NL postgres@ocp04.open-contracting.org

vm:
  nr_hugepages: 8325

ntp:
  - 0.de.pool.ntp.org
  - 1.de.pool.ntp.org
  - 2.de.pool.ntp.org
  - 3.de.pool.ntp.org

prometheus:
  node_exporter:
    smartmon: True

postgres:
  version: 15
  public_access: True
  configuration: kingfisher-replica1
  storage: ssd
  type: dw
  backup:
    configuration: kingfisher-replica1
    process_max: 6
  replication:
    primary_slot_name: replica1

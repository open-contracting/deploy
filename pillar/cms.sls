# This file configures common services for content management systems like WordPress and Wagtail.
#
# The server was initially only for the "coalition" website (open-spending.eu).

network:
  host_id: ocp21
  ipv4: 139.162.211.65
  ipv6: "2a01:7e00:e000:04e3::"
  networkd:
    template: linode
    gateway4: 139.162.211.1

logrotate:
  conf:
    php-site-logs:
      source:  php-site-logs
      context:
        php_version: '8.1'

# Directories are configured in each CMS' Pillar file.
backup:
  location: ocp-coalition-backup/site

# Sites are configured in each CMS' Pillar file.
apache:
  public_access: True

# Databases and users are configured in each CMS' Pillar file.
mysql:
  version: '8.0'
  configuration: False
  backup:
    location: ocp-coalition-backup/database

php:
  version: '8.1'  # sync with logrotate above

wordpress:
  cli_version: 2.7.1

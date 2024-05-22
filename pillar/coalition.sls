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

apache:
  public_access: True
  sites:
    coalition:
      configuration: wordpress
      servername: www.open-spending.eu
      serveraliases: ['open-spending.eu']
      context:
        user: coalition
        socket: /var/run/php/php-fpm-coalition.sock

mysql:
  version: '8.0'
  configuration: False
  databases:
    coalition_wp:
      user: coalition
  backup:
    location: ocp-coalition-backup/database

php:
  version: '8.1'  # sync with logrotate above

phpfpm:
  sites:
    coalition:
      configuration: default
      context:
        user: coalition
        listen_user: www-data
        socket: /var/run/php/php-fpm-coalition.sock

wordpress:
  cli_version: 2.7.1
  backup:
    location: ocp-coalition-backup/site

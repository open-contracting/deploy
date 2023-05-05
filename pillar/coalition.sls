network:
  host_id: ocp21
  ipv4: 139.162.211.65
  networkd:
    template: linode
    gateway4: 139.162.211.1

apache:
  public_access: True
  sites:
    coalition:
      configuration: coalition
      servername: www.open-spending.eu
      serveraliases: ['open-spending.eu']
      context:
        php_socket: /var/run/php/php-fpm-coalition.sock

phpfpm:
  sites:
    coalition:
      configuration: default
      context:
        user: coalition
        listen_user: www-data
        socket: /var/run/php/php-fpm-coalition.sock

mysql:
  version: '8.0'
  configuration: False
  databases:
    coalition_wp:
      user: coalition
#  backup:
#    location: ocp-coalition-backups/database

wordpress:
  cli_version: 2.7.1

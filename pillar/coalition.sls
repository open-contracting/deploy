backup:
  directories:
    # Must match directory in coalition/init.sls.
    /home/coalition/public_html/:
    /home/corporate/public_html/:

apache:
  sites:
    coalition:
      configuration: wordpress
      servername: www.open-spending.eu
      serveraliases: ['open-spending.eu']
      context:
        user: coalition
        socket: /var/run/php/php-fpm-coalition.sock
    corporate:
      configuration: wordpress
      servername: www.open-contracting.org
      serveraliases: ['open-contracting.org']
      context:
        user: corporate
        socket: /var/run/php/php-fpm-corporate.sock

mysql:
  databases:
    coalition_wp:
      user: coalition
    corporate_wp:
      user: corporate

phpfpm:
  sites:
    coalition:
      configuration: default
      context:
        user: coalition
        listen_user: www-data
        socket: /var/run/php/php-fpm-coalition.sock
    corporate:
      configuration: default
      context:
        user: corporate
        listen_user: www-data
        socket: /var/run/php/php-fpm-corporate.sock

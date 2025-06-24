backup:
  directories:
    # Must match directory in coalition/init.sls.
    /home/coalition/public_html/:
    /home/opencontractingorg/public_html/:

apache:
  sites:
    coalition:
      configuration: wordpress
      servername: www.open-spending.eu
      serveraliases: ['open-spending.eu']
      context:
        user: coalition
        socket: /var/run/php/php-fpm-coalition.sock
    opencontractingorg:
      configuration: wordpress
      servername: www.open-contracting.org
      serveraliases: ['open-contracting.org']
      context:
        user: opencontractingorg
        socket: /var/run/php/php-fpm-opencontractingorg.sock

mysql:
  databases:
    coalition_wp:
      user: coalition
    opencontractingorg_wp:
      user: opencontractingorg

phpfpm:
  sites:
    coalition:
      configuration: default
      context:
        user: coalition
        listen_user: www-data
        socket: /var/run/php/php-fpm-coalition.sock
    opencontractingorg:
      configuration: default
      context:
        user: opencontractingorg
        listen_user: www-data
        socket: /var/run/php/php-fpm-opencontractingorg.sock

backup:
  directories:
    /home/coalition/public_html/:

apache:
  sites:
    coalition:
      configuration: wordpress
      servername: www.open-spending.eu
      serveraliases: ['open-spending.eu']
      context:
        user: coalition
        socket: /var/run/php/php-fpm-coalition.sock

mysql:
  databases:
    coalition_wp:
      user: coalition

phpfpm:
  sites:
    coalition:
      configuration: default
      context:
        user: coalition
        listen_user: www-data
        socket: /var/run/php/php-fpm-coalition.sock
      cron:
        contact:
          - sysadmin@open-contracting.org
        ignore:
          - a-fake-plugin.php

wordpress:
  sites:
    coalition:
      plugins:
        - auto-update-plugin
        - disable-comments-pingbacks
        - fathom-analytics
        - mail-from
      context:
        FATHOM_ANALYTICS_ID: LNRZMMVR

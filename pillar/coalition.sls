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
        # Reproduce with: wp cron event run --quiet --all
        # https://developer.wordpress.org/reference/classes/wp_site_health/detect_plugin_theme_auto_update_issues/
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

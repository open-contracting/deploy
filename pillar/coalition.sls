backup:
  directories:
    /home/coalition/public_html/:
      # Page cache, regenerated on demand.
      exclude: --exclude=wp-content/cache

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
        # This site is near-idle. Reap, don't hold, idle workers.
        pm: dynamic
        pm_max_children: 6
        pm_max_requests: 500
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
      database: coalition_wp
      plugins:
        - auto-update-plugin
        - disable-admin-view-transitions
        - disable-comments-pingbacks
        - fathom-analytics
        - mail-from
      context:
        FATHOM_ANALYTICS_ID: LNRZMMVR

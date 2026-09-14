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

wordpress:
  sites:
    coalition:
      database: coalition_wp
      cron:
        contact:
          - sysadmin@open-contracting.org
        ignore:
          # Reproduce with: wp cron event run --quiet --all
          # https://developer.wordpress.org/reference/classes/wp_site_health/detect_plugin_theme_auto_update_issues/
          - a-fake-plugin.php
      constants:
        # https://developer.wordpress.org/advanced-administration/upgrade/upgrading/#constant-to-configure-core-updates
        WP_AUTO_UPDATE_CORE: "'minor'"
      mu_plugins:
        - auto-update-plugin
        - fathom-analytics
      context:
        FATHOM_ANALYTICS_ID: LNRZMMVR
      checks:
        enabled:
          - integrity
          - updates
          - silent
        premium_plugins:
          - advanced-custom-fields-pro

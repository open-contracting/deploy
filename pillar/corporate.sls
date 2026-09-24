backup:
  directories:
    /home/corporate/public_html/:
      # Page cache, regenerated on demand.
      exclude: --exclude=wp-content/cache

apache:
  sites:
    corporate:
      configuration: wordpress
      servername: www.open-contracting.org
      serveraliases: ['open-contracting.org']
      context:
        user: corporate
        socket: /var/run/php/php-fpm-corporate.sock

mysql:
  databases:
    corporate_wp:
      user: corporate

phpfpm:
  sites:
    corporate:
      configuration: default
      context:
        user: corporate
        listen_user: www-data
        socket: /var/run/php/php-fpm-corporate.sock
        request_slowlog_timeout: 2s
        env:
          # Increased to resolve WordPress menu issue.
          php_value[max_input_vars]: 3000
          php_value[memory_limit]: 256M
          php_value[upload_max_filesize]: 8M
          php_value[post_max_size]: 10M

wordpress:
  sites:
    corporate:
      database: corporate_wp
      cron:
        contact:
          - sysadmin@open-contracting.org
          - support+ocp@theideabureau.co
      mu_plugins:
        - acf-field-group-cache
        - autosave-lookup
        - google-tag-manager
        - items-per-page
      context:
        GTM_CONTAINER_ID: GTM-WMV9C5F
        ITEMS_PER_PAGE: 10
      checks:
        enabled:
          - integrity
        premium_plugins:
          - acfml
          - advanced-custom-fields-pro
          - gravityforms
          - gravityformsturnstile
          - sitepress-multilingual-cms
          - wp-migrate-db-pro
          - wp-seo-multilingual
          - wpml-string-translation
          # WP Migrate's must-use plugin.
          - wp-migrate-db-pro-compatibility
          # Closed on wordpress.org.
          - page-for-post-type

ssh:
  corporate:
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxMhl3ZYqr5wz/aqJQJF37jKBIlRXrngPHgf7NVk+Ac ben@theideabureau.co
    # Idea Bureau uses https://buddy.works for deployment.
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVbETLViRXbSi3kaiCLKtWHkEI9L5jWj652PEVzQkODTWrvai+pEci/0WE/F7pKa+CcuYADSogKCqdGxQuPGOsS47yVYtY7Zkkzzd7bXbQnNTCCY2ziNH9yQjNWCJtHl5CTcl3hlGplB46pu95x9K+TSZwrf8qg+FXCdP0k7HRJe1XBmVc+tj0jdd5CN0v4m/vrXYLtOO81CqKiARQsIED3pSXxJRzVth5PRTNDX2tEPsJ/XUCsFWYRJU/46MmYZ4oBQ9shnkunjxMghqaSjtYBEK9gN1aSfjMy33CdE56v9skklCecl+uSkv2pfTomXyTHQXXvMmESv4du0vzJlIR Buddy Works

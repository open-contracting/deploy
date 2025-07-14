backup:
  directories:
    /home/corporate/public_html/:

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

ssh:
  corporate:
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxMhl3ZYqr5wz/aqJQJF37jKBIlRXrngPHgf7NVk+Ac ben@theideabureau.co

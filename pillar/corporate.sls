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
        extra_overrides:
         - AuthConfig

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
        env:
          php_value[max_input_vars]: 2000

ssh:
  corporate:
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxMhl3ZYqr5wz/aqJQJF37jKBIlRXrngPHgf7NVk+Ac ben@theideabureau.co
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCVbETLViRXbSi3kaiCLKtWHkEI9L5jWj652PEVzQkODTWrvai+pEci/0WE/F7pKa+CcuYADSogKCqdGxQuPGOsS47yVYtY7Zkkzzd7bXbQnNTCCY2ziNH9yQjNWCJtHl5CTcl3hlGplB46pu95x9K+TSZwrf8qg+FXCdP0k7HRJe1XBmVc+tj0jdd5CN0v4m/vrXYLtOO81CqKiARQsIED3pSXxJRzVth5PRTNDX2tEPsJ/XUCsFWYRJU/46MmYZ4oBQ9shnkunjxMghqaSjtYBEK9gN1aSfjMy33CdE56v9skklCecl+uSkv2pfTomXyTHQXXvMmESv4du0vzJlIR Buddy.works

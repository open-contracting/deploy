toucan-deps:
  pkg.installed:
    - pkgs:
      - libyajl-dev # OCDS Kit performance

include:
  - django

root_toucan:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_toucan

{% from 'lib.sls' import apache %}

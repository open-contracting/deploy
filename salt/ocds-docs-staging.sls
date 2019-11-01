include:
  - ocds-docs-common
  - apache

add-travis-key-for-ocds-docs-dev:
    ssh_auth.present:
        - user: ocds-docs
        - source: salt://private/ocds-docs/ssh_authorized_keys_from_travis

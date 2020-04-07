include:
  - apache
  - ocds-docs-common

add-ci-key-for-ocds-docs-dev:
  ssh_auth.present:
      - source: salt://private/ocds-docs/ssh_authorized_keys_from_travis
      - user: ocds-docs

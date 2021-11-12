# Expects an additional argument defining the server hostname. Example:
#
#   salt-ssh 'example' state.apply 'onboarding,core*' pillar='{"host_id":"ocpXX"}'
#
# `order` is used, to ensure these states run before any core states.

update all packages:
  pkg.uptodate:
    - order: 1
    - refresh: True
    - dist_upgrade: True

system.reboot:
  module.run:
   - order: last

apache:
  https: force
  environment: live
  subdomain: ''
  # These are unique to ocds-docs-live.
  ocds_cove_backend: https://cove.live.cove.opencontracting.uk0.bigv.io
  oc4ids_cove_backend: https://cove-live.oc4ids.opencontracting.uk0.bigv.io
  timeout: 1830  # 30 sec longer than cove's uwsgi.harakiri

https: 'force'
# The URL to which /review is proxied.
ocds_cove_backend: https://cove.live.cove.opencontracting.uk0.bigv.io
oc4ids_cove_backend: https://cove-live.oc4ids.opencontracting.uk0.bigv.io
cove:
  # This is intended to be a *little* larger than uwsgi_harakiri.
  apache_on_docs_server_proxy_timeout: 1830

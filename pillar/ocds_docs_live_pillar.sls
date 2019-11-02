# For salt/ocds-docs-common.sls
https: force
environment: live
subdomain: ''
testing_subdomain: live.

# For salt/ocds-docs-live.sls
ocds_cove_backend: https://cove.live.cove.opencontracting.uk0.bigv.io
oc4ids_cove_backend: https://cove-live.oc4ids.opencontracting.uk0.bigv.io
# This is intended to be a *little* larger than uWSGI's harakiri.
apache_on_docs_server_proxy_timeout: 1830

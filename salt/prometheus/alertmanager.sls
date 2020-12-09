{% from 'lib.sls' import prometheus_service %}

include:
  - apache.public
  - apache.modules.proxy_http

{{ prometheus_service('alertmanager') }}

{% from 'lib.sls' import prometheus_service %}

{{ prometheus_service('prometheus') }}

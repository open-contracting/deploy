{% from 'lib.sls' import apache, set_firewall %}

include:
  - apache.letsencrypt

{{ set_firewall("PUBLIC_HTTP") }}
{{ set_firewall("PUBLIC_HTTPS") }}

# https://github.com/OpenDataServices/opendataservices-deploy/commit/34f093188b9d0d58fc2bed76643b22afa3b9ff83
# https://github.com/open-contracting/deploy/issues/19
{{ apache('000-default') }}

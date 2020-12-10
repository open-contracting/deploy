{% from 'lib.sls' import apache %}

include:
  - apache.letsencrypt

# https://github.com/OpenDataServices/opendataservices-deploy/commit/34f093188b9d0d58fc2bed76643b22afa3b9ff83
# https://github.com/open-contracting/deploy/issues/19
{{ apache('000-default', {'configuration': '000-default', 'servername': grains.fqdn}) }}

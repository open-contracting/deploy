include:
  - django

{% from 'lib.sls' import apache %}

# Set up a redirect from an old server name.
{{ apache('ocdskit-web-redirects.conf') }}


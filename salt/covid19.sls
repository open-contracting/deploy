{% from 'lib.sls' import set_firewall %}

{{ set_firewall("PUBLIC_HTTP") }}
{{ set_firewall("PUBLIC_HTTPS") }}
{{ set_firewall("PUBLIC_SSH") }}

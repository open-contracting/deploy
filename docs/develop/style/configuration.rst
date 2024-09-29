Configuration file style guide
==============================

To make a configuration file more reusable:

-  Use values from Pillar data, instead of hardcoding values.
-  Set sensible defaults, for example:

   .. code-block:: jinja

      {{ bind_address|default('127.0.0.1') }}

-  Make values optional, for example:

   .. code-block:: jinja

      {%- if 'ipv6' in pillar.apache %}
      Listen [{{ pillar.apache.ipv6 }}]:443
      {%- endif %}

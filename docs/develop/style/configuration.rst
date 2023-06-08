Configuration file style guide
==============================

To make a configuration file more reusable:

-  Use values from Pillar data, instead of hardcoding values.
-  Set sensible defaults, for example:

   .. code-block:: jinja

      {{ bind_address|default('127.0.0.1') }}

   If the key contains a hyphen:

   .. code-block:: jinja

      {{ entry.uwsgi.max-requests|default(1000) }}

-  Make values optional, for example:

   .. code-block:: jinja

      {%- if 'cheaper' in entry.uwsgi %}
      cheaper = {{ entry.uwsgi.cheaper }}
      {%- endif %}

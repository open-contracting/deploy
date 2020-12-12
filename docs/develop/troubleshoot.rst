Troubleshoot
============

Avoid Pillar gotchas
--------------------

-  If unquoted, ``yes``, ``no``, ``true`` and ``false`` are parsed as booleans. Use quotes to parse as strings.
-  A blank value is parsed as ``None``. Use the empty string ``''`` to parse as a string.

For example, below, if ``a`` is equal to an empty string, then ``b`` will be ``None``:

.. code-block:: jinja

   {% set extracontext %}
   b: {{ a }}
   {% endset %}

Instead, surround it in quotes:

.. code-block:: jinja

   {% set extracontext %}
   b: "{{ a }}"
   {% endset %}

Language style guides
=====================

Jinja templating language
-------------------------

Use dot notation:

.. code-block:: jinja

   {{ pillar.host_id }}
   {{ grains.kernel }}

**AVOID** bracket notation:

.. code-block:: jinja

   {{ pillar['host_id'] }}  # AVOID
   {{ grains['kernel'] }}  # AVOID

To test whether a mapping key is present, use the ``in`` operator:

.. code-block:: jinja

   {% if 'child' in pillar.parent %}

To test whether an optional boolean is true, use the ``.get()`` method:

.. code-block:: jinja

   {% if pillar.parent.get('enabled') %}

If a Pillar key might not be set, use ``.get()``:

.. code-block:: jinja

   {{ pillar.parent.get('child') }}

If many parts of a Pillar key might not be set, use ``salt['pillar.get']()``:

.. code-block:: jinja

   {{ salt['pillar.get']('parent:child') }}

Note the colon (``:``) between ``parent`` and ``child``.

YAML data-serialization language
--------------------------------

Pillar keys
  To allow the use of dot notation in Jinja templates, prefer underscores to hyphens in Pillar keys.
State IDs
  While state IDs with spaces are easier to read, they are also easier to mistype: for example, in ``watch_in`` arguments. As such, prefer hyphens to spaces in state IDs.
Booleans
  Capitalize ``True`` and ``False``, for consistency.

Avoid gotchas
~~~~~~~~~~~~~

-  If unquoted, ``yes``, ``no``, ``True`` and ``False`` are parsed as booleans in YAML. Use quotes to parse as strings.
-  A blank value is parsed as ``None`` in YAML. Use the empty string ``''`` to parse as a string.

For example, in the Jinja snippet below, if ``a`` is equal to an empty string, then ``b`` will be ``None``:

.. code-block:: jinja

   {% set extracontext %}
   b: {{ a }}
   {% endset %}

Instead, surround it in quotes:

.. code-block:: jinja

   {% set extracontext %}
   b: "{{ a }}"
   {% endset %}

Language style guides
=====================

Jinja templating language
-------------------------

Notation
~~~~~~~~

Use dot notation:

.. code-block:: jinja

   {{ pillar.host_id }}
   {{ grains.kernel }}

**AVOID** bracket notation:

.. code-block:: jinja

   {{ pillar['host_id'] }}  # AVOID
   {{ grains['kernel'] }}  # AVOID

.. note::

   To allow the use of dot notation in Jinja, prefer underscores to hyphens in Pillar keys.

Optional mapping keys
~~~~~~~~~~~~~~~~~~~~~

To test whether a key is present in a mapping, use the ``in`` operator:

.. code-block:: jinja

   {% if 'child' in pillar.parent %}

.. note::

   Maintainers can check this style rule with this regular expression:

   .. code-block:: none

      if .*get\(.(?!(?:autoremove|compilemessages|enabled|public_access|replication|smartmon|summarystats)\b)

To iterate over an optional mapping:

.. code-block:: jinja

   {% for key, value in pillar.mykey|items %}

Or:

.. code-block:: jinja

   {% for key, value in salt['pillar.get']('parent:child', {}).items() %}

.. note::

   Maintainers can check this style rule with this regular expression:

   .. code-block:: none

      \bif\b.*\n.*%.*\bfor\b

Optional list keys
~~~~~~~~~~~~~~~~~~

To iterate over an optional list:

.. code-block:: jinja

   {% for value in pillar.mykey|default([]) %}

Or:

.. code-block:: jinja

   {% for value in salt['pillar.get']('parent:child', []) %}

Optional boolean keys
~~~~~~~~~~~~~~~~~~~~~

To test whether an optional boolean is true, use the ``.get()`` method:

.. code-block:: jinja

   {% if pillar.parent.get('enabled') %}

Optional keys
~~~~~~~~~~~~~

To get an optional key with a default value:

.. code-block:: jinja

   {{ entry.mykey|default(123) }}

If the default value is the empty string:

.. code-block:: jinja

   {{ entry.mykey|default }}

.. note::

   Maintainers can check this style rule with this regular expression:

   .. code-block:: none

      (?<!salt\['pillar)\.get\([^\s-]+,

If many parts of a Pillar key might not be set, use ``salt['pillar.get']()``:

.. code-block:: jinja

   {{ salt['pillar.get']('parent:child') }}

Note the colon (``:``) between ``parent`` and ``child``.

YAML data-serialization language
--------------------------------

Capitalize the ``True`` and ``False`` booleans, for consistency.

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

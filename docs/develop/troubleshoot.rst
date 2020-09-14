Troubleshoot
============

.. _increase-verbosity:

Increase verbosity
------------------

.. code-block:: bash

   salt-ssh -v all TARGET FUNCTION

Salt hangs inexplicably
-----------------------

If you haven't previously connected to a server using SSH, then ``salt-ssh`` will log a ``TRACE``-level message like:

.. code-block:: none

   The authenticity of host 'example.com (101.2.3.4)' can't be established.
   ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
   Are you sure you want to continue connecting (yes/no/[fingerprint])?

You can also experience this issue if anyone changes the hostnames in the ``salt-config/roster`` file.

Unless you :ref`increase verbosity<increase-verbosity>`, you won't see this message, and ``salt-ssh`` will appear to hang.

To fix this, simply connect to the server using SSH, then re-run the ``salt-ssh`` command, for example:

.. code-block:: bash

   ssh root@live.standard.open-contracting.org

.. note::

   It is **not recommended** to use the ``-i`` (``--ignore-host-keys``) option, as this disables strict host key checking, allowing for man-in-the-middle attacks.

.. _watch-salt-activity:

Watch Salt activity
-------------------

If you want to check whether a deployment is simply slow or actually stalled, perform these steps:

#. Find the server's IP or fully-qualified domain name in the roster:

   .. code-block:: bash

      cat salt-config/roster

#. Open a secondary terminal to connect to the server as root, for example:

   .. code-block:: bash

      ssh root@live.docs.opencontracting.uk0.bigv.io

#. Watch the processes on the server:

   .. code-block:: bash

      watch -n 1 pstree

#. Look at the lines below these:

.. code-block:: none

    |-sshd-+-sshd---bash---watch
    |      |-sshd---bash---watch---watch---sh---pstree

Then, once the deployment is done:

#. Stop watching the processes, e.g. with ``Ctrl-C``
#. Disconnect from the server, e.g. with ``Ctrl-D``

Avoid Pillar gotchas
--------------------

-  If unquoted, ``yes``, ``no``, ``true`` and ``false`` are parsed as booleans. Use quotes to parse as strings.
-  A blank value is parsed as ``None``. Use the empty string ``''`` to parse as a string.
-  Below, if ``a`` is equal to an empty string, then ``b`` will be ``None``:

   .. code-block:: none

      {% set extracontext %}
      b: {{ a }}
      {% endset %}

   Instead, surround it in quotes:

   .. code-block:: none

      {% set extracontext %}
      b: "{{ a }}"
      {% endset %}

Check history
-------------

If you don't understand why a configuration exists, it's useful to check its history.

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. You can `browse <https://github.com/OpenDataServices/opendataservices-deploy/tree/7a5baff013b888c030df8366b3de45aae3e12f9e>`__ that repository from before the switchover (August 5, 2019). That repository was itself re-organized at different times. You can browse `before moving content from *.conf to *.conf.include <https://github.com/OpenDataServices/opendataservices-deploy/tree/4dbea5122e1fc01221c8d051efc99836cef98ccb>`__ (June 5, 2019).

Deploy a service
================

As with other deployment tasks, do the :doc:`setup tasks<setup>` before the steps below. If you run into trouble, read the :doc:`troubleshoot` guide.

1. Run Salt function
--------------------

Deploy a service
~~~~~~~~~~~~~~~~

Indicate the desired target and use the ``state.apply`` function, for example:

.. code-block:: bash

    ./run.py --state-output=changes 'docs' state.apply

The ``state.apply`` function often completes within one minute.

.. note::

   If you want to check whether a deployment is simply slow (frequent) or actually stalled (rare), :ref:`watch Salt's activity<watch-salt-activity>`.

.. tip::

   To override Pillar data, use, for example:

   .. code-block:: bash

      ./run.py --state-output=changes 'mytarget-dev' state.apply pillar='{"python_apps":{"myapp":{"git":{"branch":"BRANCH_NAME"}}}}'

Deploy part of a service
~~~~~~~~~~~~~~~~~~~~~~~~

To `run a specific state file <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.state.html#salt.modules.state.sls>`__, run, for example:

.. code-block:: bash

   ./run.py --state-output=changes 'docs' state.sls elasticsearch

To `run a specific SLS ID <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.state.html#salt.modules.state.sls_id>`__, run, for example:

.. code-block:: bash

   ./run.py --state-output=changes '*' state.sls_id root_authorized_keys core.sshd

.. note::

   The requirements of the state file or SLS ID must be met. For example, to only create a PostgreSQL user, run:

   .. code-block:: bash

      ./run.py --state-output=changes 'kingfisher-main' state.sls postgres,postgres.backup

2. Check Salt output
--------------------

Look for these lines at the end of the output in the primary terminal:

.. code-block:: none

    Summary for docs
    -------------
    Succeeded: ## (changed=#)
    Failed:     0

Then:

#. Check that the app is still responding in your web browser.
#. If there are any failed states, look for each in the output (red text) (or search for ``Result: False``) and debug.
#. If there are any changed states, look for each in the output (blue text) (or grep for ``Changes:   \n[^\n-]``) and verify the changes.

Common changed states are:

Function: service.running, ID: apache2
  Apache was reloaded

States that always report changes:

-  `cmd.run <https://docs.saltproject.io/en/latest/ref/states/all/salt.states.cmd.html>`__, unless ``onchanges`` is specified
-  `pip.installed <https://github.com/saltstack/salt/issues/24216>`__, if ``upgrade`` is set
-  ``postgres_privileges.present``, if ``object_name`` is ``ALL``

3. Manual cleanup
-----------------

If you :doc:`removed a Salt configuration<../develop/update/delete>`, follow the linked steps to cleanup manually.

If you changed the server name of a virtual host that uses HTTPS, :ref:`ssl-certificates`.

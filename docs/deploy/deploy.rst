Deploy an app
=============

1. Watch Salt activity
----------------------

.. note::

   This step is optional.

#. Find the server's IP or fully-qualified domain name in the roster:

   .. code-block:: bash

      cat salt-config/roster

#. Open a secondary terminal to connect to the server as root, for example:

   .. code-block:: bash

      ssh root@live.docs.opencontracting.uk0.bigv.io

#. Watch the processes on the server:

   .. code-block:: bash

      watch -n 1 pstree

#. Access your primary terminal

2. Run Salt function
--------------------

To deploy an app, indicate the desired target and the ``state.apply`` function, for example:

.. code-block:: bash

    salt-ssh -i 'ocds-docs-staging' state.apply

Setting ``-i`` disables StrictHostKeyChecking, which avoids an extra prompt the first time you connect to a host.

If the output has an error of ``Unable to detect Python-2 version``, you don't have Python 2.7 in your PATH. To fix this, if you use ``pyenv``, run, for example:

.. code-block:: bash

    pyenv shell system

The ``state.apply`` function often completes within one minute. You can ignore this warning: ``DeprecationWarning: encoding is deprecated, Use raw=False instead``.

In the secondary terminal, to monitor what Salt is doing, look at the lines below these:

.. code-block:: none

    |-sshd-+-sshd---bash---watch
    |      |-sshd---bash---watch---watch---sh---pstree

3. Check Salt output
--------------------

Look for these lines at the end of the output in the primary terminal:

.. code-block:: none

    Summary for ocds-docs-staging
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
Function: cmd.run, ID: prometheus-client-apache-password
  This change is a false positive

For a Django app, common changed states are:

Function: git.latest
  A new commit was deployed
Function: virtualenv.managed
  This change is a false positive
Function: cmd.run, Name: . .ve/bin/activate; python manage.py migrate --noinput
  Django migrations were applied
Function: cmd.run, Name: . .ve/bin/activate; python manage.py collectstatic --noinput
  Static files were copied
Function: service.running, ID: uwsgi
  uWSGI was reloaded

4. Manual cleanup
-----------------

If you :ref:`changed the server name<change-server-name>` or :ref:`deleted a service, package, user, file, or authorized key<remove-content>`, follow the linked steps to cleanup manually.

5. Close the secondary terminal
-------------------------------

.. note::

   Skip this step if you didn't watch Salt activity on the remote server.

#. Stop watching the processes, e.g. with ``Ctrl-C``
#. Disconnect from the server, e.g. with ``Ctrl-D``

Quick reference
===============

.. _tmux:

Perform a long-running operation
--------------------------------

If an operation will take a long time to run, run it in a terminal multiplexer (``tmux``), in case you lose your connection to the server. To open a session in ``tmux``, use this command, replacing ``initials-task-description`` with your initials and a short description of your task. By including your initials, it is easy for others to determine to whom the session belongs – especially if you forget to close it.

.. code-block:: bash

   tmux new -s initials-task-description

If you lose your connection to the server, re-attach to your session with:

.. code-block:: bash

   tmux attach-session -t initials-task-description

To manually detach from a session, press ``Ctrl-b``, release both keys, then press ``d``.

If you forget the name of your session, list all sessions with:

.. code-block:: bash

   tmux ls

Run a single state
------------------

To `run a specific state <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.state.html#salt.modules.state.sls_id>`__, run, for example:

.. code-block:: bash

   ./run.py '*' state.sls_id root_authorized_keys core.sshd

.. _restart-service:

Restart a service
-----------------

To restart a service, run, for example:

.. code-block:: bash

   ./run.py TARGET service.restart uwsgi

To restart a service managed by `Supervisor <http://supervisord.org>`__, run, for example:

.. code-block:: bash

   ./run.py TARGET supervisord.restart scrapyd

Reboot a server
---------------

.. code-block:: bash

   ./run.py TARGET system.reboot

Rescale a server
----------------

The Bytemark Panel makes it easy to scale a server (number of cores and GiB of RAM).

If appropriate, update the service's ``limit-as`` uWSGI setting.

Maintain a server
=================

Perform a long-running operation
--------------------------------

If an operation will take a long time to run, run it in a terminal multiplexer (``tmux``), in case you lose your connection to the server. To open a session in ``tmux``, use this command, replacing ``initials-task-description`` with your initials and a short description of your task. By including your initials, it is easy for others to determine to whom the session belongs – especially if you forget to close it.

.. code-block:: bash

   tmux new -s initials-task-description

If you lose your connection to the server, re-attach to your session with:

.. code-block:: bash

   tmux attach-session -t initials-task-description

If you forget the name of your session, list all sessions with:

.. code-block:: bash

   tmux ls

Clean root user directory
-------------------------

#. Run:

   .. code-block:: bash
   
      salt-ssh '*' cmd.run 'ls'

#. Leave any ``post.install.log`` files
#. Delete any ``index.html*`` files

   -  These are created when a developer runs ``wget`` commands to e.g. test proxy settings.

Upgrade packages
----------------

All servers use the `unattended-upgrades package <https://help.ubuntu.com/lts/serverguide/automatic-updates.html>`__ for security updates.

To show the upgradable packages, run:

.. code-block:: bash

   salt-ssh '*' pkg.list_upgrades

Auto-remove packages
--------------------

To show the packages that were automatically installed and are no longer required:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.autoremove list_only=True

To remove these, run:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.autoremove purge=True

To show the packages that were removed but not purged, run:

.. code-block:: bash

   salt-ssh '*' pkg.list_pkgs removed=True

Upgrade Ubuntu
--------------

To determine the current releases, run:

.. code-block:: bash

   salt-ssh '*' cmd.run 'lsb_release -a'

To check the long term support of the releases, consult the `Ubuntu documentation <https://ubuntu.com/about/release-cycle>`__.

Check mail
----------

Connect to a server, for example:

.. code-block:: bash

   ssh root@process.kingfisher.open-contracting.org

Open the mailbox:

.. code-block:: bash

   mail

You might see a lot of repeat messages.

Here are common `commands <http://www.johnkerl.org/doc/mail-how-to.html>`__:

-  number: open that message
-  ``h``: show a screen of messages
-  ``z``: go to the next screen
-  ``d 5-10``: delete the messages 5 through 10
-  ``d *``: delete all messages
-  ``q``: save changes and exit
-  ``x``: exit without saving changes

In most cases, all messages can be ignored and deleted.

Check that no messages were saved:

.. code-block:: bash

    ls /root/mbox

Repeat for other users with mail:

.. code-block:: bash

   ls -1 /var/mail

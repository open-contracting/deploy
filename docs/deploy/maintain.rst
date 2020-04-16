Maintain a server
=================

For tasks related to upgrading packages, see :doc:`packages`.

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

Clean root user directory
-------------------------

#. Run:

   .. code-block:: bash

      salt-ssh '*' cmd.run 'ls'

#. Leave any ``post.install.log`` files
#. Delete any ``index.html*`` files

   -  These are created when a developer runs ``wget`` commands to e.g. test proxy settings.

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

Check mail
----------

Find saved messages across servers:

.. code-block:: bash

   salt-ssh '*' cmd.run 'find /root /home/* -maxdepth 0 -name mbox'

Find mailboxes with mail across servers:

.. code-block:: bash

   salt-ssh '*' cmd.run 'find /var/mail -type f -not -size 0'

Connect to a server, for example:

.. code-block:: bash

   ssh root@process.kingfisher.open-contracting.org

Open the mailbox:

.. code-block:: bash

   mail -f /var/mail/root

You might see a lot of repeat messages.

Here are common `commands <http://www.johnkerl.org/doc/mail-how-to.html>`__:

-  number: open that message
-  ``h``: show a screen of messages
-  ``z``: go to the next screen
-  ``d 5-10``: delete the messages 5 through 10
-  ``d *``: delete all messages
-  ``q``: save changes and exit
-  ``x``: exit without saving changes

In most cases, all messages can be ignored and deleted. Relevant messages might include:

Failed cron jobs
   Try to correct the failure
Failed attempts to use sudo
   If the attempt is not attributable to a team member, discuss security measures

Restart services
----------------

To restart a service, run, for example:

.. code-block:: bash

   salt-ssh TARGET service.restart uwsgi

To reboot a server:

.. code-block:: bash

   salt-ssh TARGET system.reboot

Upgrade Ubuntu
--------------

To determine the current releases, run:

.. code-block:: bash

   salt-ssh '*' cmd.run 'lsb_release -a'

To check the long term support of the releases, consult the `Ubuntu documentation <https://ubuntu.com/about/release-cycle>`__.


Be aware of security updates
----------------------------

Generally be aware of the various relevant tech communities, so when a big security issue happens work can be done straight away and it does not wait until the normal schedule. Some places to check include:

* `Ubuntu Security Website <https://usn.ubuntu.com/>`__
* `Ubuntu Email List Website <https://lists.ubuntu.com/archives/ubuntu-security-announce/>`__

Manual Checks
-------------

It's good to occasionally manually check servers and look for anything that other systems might have missed or anything that might become an issue later. For instance:

* Review logs in `/var/log`, especially system ones, for anything out of the ordinary.
* Review machine resource usage as recorded in Prometheus. Maybe scale servers up or down in response.

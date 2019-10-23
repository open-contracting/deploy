Kingfisher tasks
================

Check mail
----------

Connect to the server:

.. code-block:: bash

   ssh root@process.kingfisher.open-contracting.org

Open the mailbox:

.. code-block:: bash

   mail

You will most likely see a lot of repeat messages.

Here are common `commands <http://www.johnkerl.org/doc/mail-how-to.html>`__:

-  number: open that message
-  ``h``: show a screen of messages
-  ``z``: go to the next screen
-  ``d 5-10``: delete the messages 5 through 10
-  ``d *``: delete all messages
-  ``q``: save changes and exit
-  ``x``: exit without saving changes

In most cases, all messages can be ignored and deleted.

Repeat for other users with mail:

.. code-block:: bash

   ls -1 /var/mail

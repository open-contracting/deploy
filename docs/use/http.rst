Connect to a service (HTTP)
===========================

.. _netrc:

Create a .netrc file
--------------------

.. note::

   Many services are protected by `Basic authentication <https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication>`__. When accessing these services in a web browser, you typically need to enter your credentials *only once*, and your browser will submit the ``Authorization`` header on subsequent requests. When accessing these services from the command line, you typically need to enter your credentials *every time*. Creating and using a ``.netrc`` file **on your computer** avoids this extra work.

To create (or append credentials to) a ``~/.netrc`` file:

#. Run, replacing ``HOSTNAME`` with the service's hostname (e.g. ``collect.kingfisher.open-contracting.org``), ``USERNAME`` with your username, and ``PASSWORD`` with your password:

   .. code-block:: bash

      echo 'machine HOSTNAME
        login USERNAME
        password PASSWORD' >> ~/.netrc

#. Check that only one section of the ``~/.netrc`` file refers to the hostname, replacing ``HOSTNAME``:

   .. code-block:: shell-session

      $ grep -A2 HOSTNAME ~/.netrc
      machine myhostname
        login myuser
        password mypass

   If there are multiple sections or an incorrect password, you must correct the file in a text editor.

#. Change the file's permissions to be readable only by the owner:

   .. code-block:: bash

      chmod 600 ~/.netrc

#. Check the permissions:

   .. code-block:: shell-session

      $ stat -f "%Sp" ~/.netrc
      -rw-------

#. Test your configuration. For example, for Kingfisher Collect:

   .. code-block:: shell-session

      $ curl -n https://collect.kingfisher.open-contracting.org/listprojects.json
      {"node_name": "ocp99", "status": "ok", "projects": ["kingfisher"]}

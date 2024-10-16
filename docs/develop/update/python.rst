Configure Python apps
=====================

The ``python_apps`` state file performs common operations for Python apps. In your app's state file, include it with:

.. code-block:: yaml

   include:
     - python_apps

If you already have an ``include`` state, add ``python_apps`` to its list.

Add basic configuration
-----------------------

In the server's Pillar file, add, for example:

.. code-block:: yaml

   python_apps:
     kingfisher_summarize:
       user: summarize
       git:
         url: https://github.com/open-contracting/kingfisher-summarize.git
         branch: main
         target: kingfisher-summarize

This will:

-  Install packages for creating Python virtual environments
-  Fetch the git repository into the ``target`` directory within the home directory of the ``user``
-  Initialize a virtual environment in a ``.ve`` directory within the repository's directory
-  Install ``requirements.txt`` with ``uv pip sync`` from `uv <https://docs.astral.sh/uv/>`__

Add configuration files
-----------------------

To create configuration files within the user's ``.config`` directory, add, for example:

.. code-block:: yaml
   :emphasize-lines: 8-9

   python_apps:
     kingfisher_summarize:
       user: summarize
       git:
         url: https://github.com/open-contracting/kingfisher-summarize.git
         branch: main
         target: kingfisher-summarize
       config:
         kingfisher-summarize/logging.json: salt://kingfisher/summarize/files/logging.json

You can add as many configuration files as you like.

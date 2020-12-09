Kingfisher
==========

Kingfisher is a family of tools to `collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__, `pre-process <https://kingfisher-process.readthedocs.io/en/latest/>`__, `summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__ and `query <https://kingfisher-colab.readthedocs.io/en/latest/>`__ OCDS data.

This page is about internal use of these tools by the Open Contracting Partnership. For your personal use, see each tool's documentation:

-  `Kingfisher Collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__
-  `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__
-  `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__

For internal use, Kingfisher Collect, Process and Summarize are deployed to a main server.

If you are a new user of Kingfisher, subscribe to the `Kingfisher Status <https://groups.google.com/a/open-contracting.org/forum/#!forum/kingfisher-status>`__ mailing list, in order to receive notifications about major downtime.

The following pages describe specific tasks for each tool:

.. toctree::

   kingfisher-collect.rst
   kingfisher-process.rst
   kingfisher-summarize.rst

Connect to servers
------------------

.. admonition:: One-time setup

   Ask a colleague to add your public SSH key to the ``ssh.kingfisher`` list in the ``pillar/kingfisher.sls`` file.

The servers have different users for different roles.

.. _connect-collect-server:

Collect
~~~~~~~

The ``ocdskfs`` user owns the deployment of Kingfisher Collect and Kingfisher Archive.

You shouldn't need to connect to the main server as the ``ocdskfs`` user, as its data and log files are readable by the ``ocdskfp`` user. Only archival scripts and system administrators should manually delete any data and log files. If you do need to connect:

.. code-block:: bash

   curl --silent --connect-timeout 1 collect.kingfisher.open-contracting.org:8255 || true
   ssh ocdskfs@collect.kingfisher.open-contracting.org

.. _connect-process-server:

Process
~~~~~~~

The ``ocdskfp`` user owns the deployments of Kingfisher Process and Kingfisher Summarize.

Connect to the main server as the ``ocdskfp`` user, to use the command-line tools of `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/cli/>`__ and `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/cli/>`__:

.. code-block:: bash

   curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
   ssh ocdskfp@process.kingfisher.open-contracting.org

This user has access to the `flatten-tool <https://flatten-tool.readthedocs.io/en/latest/usage-ocds/>`__ and `ocdskit <https://ocdskit.readthedocs.io/en/latest/>`__ command-line tools.

Analyze
~~~~~~~

Connect to the main server as the ``analysis`` user, to perform operations that are too taxing for your local computer, like flattening a large OCDS JSON file:

.. code-block:: bash

   curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
   ssh analysis@process.kingfisher.open-contracting.org

This user has access to the `jq <https://stedolan.github.io/jq/manual/>`__, `flatten-tool <https://flatten-tool.readthedocs.io/en/latest/usage-ocds/>`__ and `ocdskit <https://ocdskit.readthedocs.io/en/latest/>`__ command-line tools.

Please remember to delete your files when done.


Share files between users
-------------------------

#. Connect to the server as the user that owns the files or directories.
#. Change the files to be world-readable:

   .. code-block:: bash

      chmod -R a+r file1.json file2.json directory1/ directory2/

#. Change the files' root directory to be world-readable and world-searchable:

   .. code-block:: bash

      chmod -R a+rX /home/user/path

You can now connect to the server as another user and read and/or copy the files for modification.

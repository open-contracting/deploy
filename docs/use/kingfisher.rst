Kingfisher
==========

Kingfisher is a family of tools to `collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__, `pre-process <https://kingfisher-process.readthedocs.io/en/latest/>`__, `summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__ and `query <https://kingfisher-colab.readthedocs.io/en/latest/>`__ OCDS data.

This page is about internal use of these tools by the Open Contracting Partnership. For your personal use, see each tool's documentation:

-  `Kingfisher Collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__
-  `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__
-  `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__

For internal use, Kingfisher Collect, Process and Summarize are deployed to a data support server.

The following pages describe specific tasks for each tool:

.. toctree::

   kingfisher-collect.rst
   kingfisher-process.rst
   kingfisher-summarize.rst

.. _connect-kingfisher-server:

Connect to servers
------------------

.. admonition:: One-time setup

   Request access from James or Yohanna. (They will need :ref:`your public SSH key<add-public-key>` to add a key-value pair under the ``users`` key in the ``pillar/kingfisher_main.sls`` file.)

Connect to the data support server:

.. code-block:: bash

   curl --silent --connect-timeout 1 collect.kingfisher.open-contracting.org:8255 || true
   ssh USER@collect.kingfisher.open-contracting.org

In addition to the Kingfisher tools, users have access to these command-line tools:

-  `jq <https://stedolan.github.io/jq/manual/>`__, to query JSON data
-  `ripgrep <https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md>`__, to `grep <https://www.gnu.org/software/grep/manual/grep.html>`__, but fast
-  `flatten-tool <https://flatten-tool.readthedocs.io/en/latest/usage-ocds/>`__, to unflatten data for local load
-  `ocdskit <https://ocdskit.readthedocs.io/en/latest/>`__, to transform data for local load
-  ``unrar``, to unarchive data for local load

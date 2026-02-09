Setup
=====

Before performing any deployment task, run the *Setup* tasks below. Once done, run the *Cleanup* tasks below. If you haven't already, please follow the :doc:`../develop/get_started` guide.

1. Update deploy repositories
-----------------------------

Ensure the ``deploy``, ``pillar/private`` and ``salt/private`` repositories are on the default branch and are up-to-date. You can run this convenience script to run the appropriate ``git`` commands:

.. code-block:: bash

    ./script/update

Check the output in case there are any issues switching to the default branch or any conflicts pulling from GitHub.

.. _check-if-kingfisher-is-busy:

2. Check if Kingfisher is busy
------------------------------

.. note::

   Skip this step unless you're working on Kingfisher.

#. :ref:`Access Scrapyd's web interface<access-scrapyd-web-service>`, click *Jobs* and look under *Running*. If any spiders are running, don't deploy without the consent of data support managers.
#. :doc:`SSH<../use/ssh>` into ``kingfisher-main`` as the ``root`` user.
#. Check if any :ref:`long-running tasks<tmux>` are running, by attaching to each session in ``tmux`` to see which commands are running. If any commands would be interrupted by the deployment, don't deploy without the consent of the data support managers, who should be identified by the session names.

   To list all sessions:

   .. code-block:: bash

      for i in root $(ls -1 /home); do echo $i; su $i -c "tmux ls"; done

#. If the ``postgres`` service would be restarted by the deployment (for example, due to a configuration change or a package upgrade), check if any :ref:`long-running queries<pg-stat-activity>` are running. If there are queries with a ``state`` of ``active`` and a ``time`` greater than an hour, don't deploy without the consent of the data support managers, who should be identified by the ``usename``, ``client_addr`` or comment at the start of ``query``.

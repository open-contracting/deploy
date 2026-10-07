Setup
=====

Before deploying, run the tasks below. If you haven't already, follow the :doc:`../develop/get_started` guide.

1. Update deploy repositories
-----------------------------

Ensure the ``deploy``, ``pillar/private`` and ``salt/private`` repositories are up-to-date and on the default branch:

.. code-block:: bash

    ./script/update

Check the output in case there are any issues switching to the default branch or any conflicts pulling from GitHub.

.. _check-if-kingfisher-is-busy:

2. Check if the server is busy
------------------------------

.. note::

   Skip this step for servers other than ``kingfisher-main`` and ``registry``.

#. Check whether any spiders are running in Scrapyd, by clicking *Jobs* and looking under *Running*:

   -  ``kingfisher-main``: :ref:`Access Scrapyd's web interface<access-scrapyd-web-service>`
   -  ``registry``: https://collect.data.open-contracting.org/jobs

   If any spiders are running, :ref:`deploy without restarting Scrapyd<deploy-norestart>`. On ``kingfisher-main``, you can alternatively get the consent of the data team.

#. On ``kingfisher-main`` only:

   #. :doc:`SSH<../use/ssh>` into ``kingfisher-main`` as the ``root`` user.
   #. Check if any :ref:`long-running tasks<tmux>` are running, by attaching to each session in ``tmux`` to see which commands are running. If any commands would be interrupted by the deployment, don't deploy without the consent of the data team, who should be identified by the session names.

      To list all sessions:

      .. code-block:: bash

         for i in root $(ls -1 /home); do echo $i; su $i -c "tmux ls"; done

   #. If the ``postgres`` service would be restarted (for example, due to a configuration change or a package upgrade), check if any :ref:`long-running queries<pg-stat-activity>` are running. If there are queries with a ``state`` of ``active`` and a ``time`` greater than an hour, don't deploy without the consent of the data team, who should be identified by the ``usename``, ``client_addr`` or comment at the start of ``query``.

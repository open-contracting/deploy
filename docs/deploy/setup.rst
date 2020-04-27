Get deploy token
================

Before performing any deployment task, run the *Setup* tasks. Once done, run the *Cleanup* tasks.

.. _generic-setup:

Setup
-----

1. Update deploy repositories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ensure the ``deploy``, ``salt/private``, and ``pillar/private`` repositories are on the ``master`` branch and are up-to-date. You can run this convenience script to run the appropriate ``git`` commands:

.. code-block:: bash

    ./script/update

Check the output in case there are any issues switching to the ``master`` branch or any conflicts pulling from GitHub.

.. _check-if-kingfisher-is-busy:

2. Check if Kingfisher is busy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   Skip this step unless you're working on Kingfisher.

#. :ref:`Access Scrapyd's web interface<access-scrapyd-web-service>`, click "Jobs" and look under "Running". If any spiders are running, don't deploy without the consent of helpdesk analysts.

#. Connect to the Kingfisher server as the ``root`` user:

   .. code-block:: bash

      ssh root@collect.kingfisher.open-contracting.org

#. Check if any :ref:`long-running tasks<tmux>` are running. If any would be interrupted by the deployment, don't deploy without the consent of helpdesk analysts.

   .. code-block:: bash

      for i in root ocdskfs ocdskfp; do echo $i; su $i -c "tmux ls"; done

If you must deploy while spiders are running, see how to :ref:`deploy Kingfisher Process without losing Scrapy requests<deploy-kingfisher-process>`.

3. Get deploy token
~~~~~~~~~~~~~~~~~~~

Only one person should be making changes to a server at once. To implement this rule, the `Deploy token <https://crm.open-contracting.org/projects/ocds/wiki/Deploy_token>`__ wiki page indicates who holds the 'deploy token'. Whoever holds the deploy token is the only person who can make changes to *any* server, until the deploy token is released. If the wiki page has "Held by: <NAME>", that person holds the token; if it has "Held by: nobody", then the token is released. To hold the token:

#. Go to the `Deploy token <https://crm.open-contracting.org/projects/ocds/wiki/Deploy_token>`__ wiki page

   * If "Held by" is followed by a person's name, wait until the deploy token is released

#. Click the "Edit" link, replace "nobody" with your name and click the "Save" button

   * If this results in an edit conflict, wait until the deploy token is released

.. _generic-cleanup:

Cleanup
-------

1. Release deploy token
~~~~~~~~~~~~~~~~~~~~~~~

#. Go to the `Deploy token <https://crm.open-contracting.org/projects/ocds/wiki/Deploy_token>`__ wiki page
#. Click "Edit", replace your name with "nobody", add an entry under History, and click "Save". If any servers were rebooted, add a note to the entry.

Google Cloud Platform (GCP)
===========================

.. note::

   Use :doc:`aws`, unless an application requires access to Google-exclusive services like Google Drive.

Review projects
---------------

.. seealso::

   -  `Security recommendations <https://console.cloud.google.com/active-assist/list/security/recommendations?organizationId=1015889055088>`__

Periodically review `all projects <https://console.cloud.google.com/cloud-resource-manager?organizationId=1015889055088>`__:

-  Review `Enabled APIs & services <https://console.cloud.google.com/apis/credentials?project=ocp-library>`__, or:

   .. code-block:: bash

      gcloud services list --enabled --project=$PROJECT

-  Review `Credentials <https://console.cloud.google.com/apis/credentials?project=ocp-library>`__, or:

   .. code-block:: bash

      gcloud iam service-accounts list --project=$PROJECT

   .. code-block:: bash

      gcloud asset search-all-iam-policies --scope=projects/$PROJECT

   .. code-block:: bash

      for account in (gcloud iam service-accounts list --project=$PROJECT --format="value(email)")
          echo "== $account"
          gcloud iam service-accounts keys list --iam-account=$account --managed-by=user
      end

-  Review `Asset Inventory <https://console.cloud.google.com/iam-admin/asset-inventory/resources?project=ocp-library>`__, or:

   .. code-block:: bash

      gcloud asset search-all-resources --scope=projects/$PROJECT --format="table(assetType, displayName, location, state, createTime)" \
        | grep -vE 'cloudresourcemanager\.googleapis\.com/Project|logging\.googleapis\.com/(LogBucket|LogSink)|iam\.googleapis\.com/ServiceAccount|serviceusage\.googleapis\.com/Service'

   ..
      cloudresourcemanager\.googleapis\.com/Project
         The project itself.
      logging\.googleapis\.com/(LogBucket|LogSink)
         The _REQUIRED and _DEFAULT LogBucket and LogSink are created automatically.
      iam\.googleapis\.com/ServiceAccount
         Use the `gcloud iam` commands above.
      serviceusage\.googleapis\.com/Service
         Use the `gcloud services` command above.

-  Review history in the `Activity tab <https://console.cloud.google.com/logs/query?organizationId=1015889055088&project=project=ocp-library>`__, or:

   .. code-block:: bash

      gcloud logging read 'severity>=DEFAULT' --project=$P --freshness=400d --limit=30 --order=desc \
        --format="table(timestamp, resource.type, protoPayload.methodName, protoPayload.authenticationInfo.principalEmail)"

Known projects
~~~~~~~~~~~~~~

.. tab-set::

   .. tab-item:: DREAM BI

      Project ID
        ``dream-bi``
      Contact
        Andrii
      Documentation
        -  `bi.dream.gov.ua-qlikauth <https://github.com/open-contracting/bi.dream.gov.ua-qlikauth>`__
        -  `vibes <https://github.com/open-contracting/vibes/blob/main/google-analytics/manage.py>`__
      Configuration
        -  ``GOOGLE_CLIENT_ID`` and ``GOOGLE_CLIENT_SECRET`` in `deploy-pillar-private <https://github.com/open-contracting/deploy-pillar-private>`__
        -  ``GOOGLE_APPLICATION_CREDENTIALS`` in `vibes <https://github.com/open-contracting/vibes/blob/main/google-analytics/manage.py>`__
      APIs
        See `Enabled APIs & services <https://console.cloud.google.com/apis/dashboard?project=dream-bi>`__
      Credentials
        -  ``DREAM BI Qlik login`` for Qlik Sense Authentication API
        -  ``google-analytics-data@dream-bi.iam.gserviceaccount.com`` to use APIs in `vibes <https://github.com/open-contracting/vibes/blob/main/google-analytics/manage.py>`__

   .. tab-item:: GAM

      Project ID
        ``gam-project-9yro6``
      Contact
        James
      Documentation
        `Google Apps Manager (GAM) <https://github.com/GAM-team/GAM>`__
      Configuration
        ``~/.gam/`` directory
      APIs
        See `Enabled APIs & services <https://console.cloud.google.com/apis/dashboard?project=gam-project-9yro6>`__
      Credentials
        -  ``GAM`` for ``gam`` commands
        -  ``gam-project-9yro6@gam-project-9yro6.iam.gserviceaccount.com`` for ``gam user`` commands
        -  `Domain-wide Delegation <https://admin.google.com/ac/owl/domainwidedelegation>`__
        -  `App Access Control <https://admin.google.com/ac/owl/list?tab=configuredApps>`__

   .. tab-item:: GYB

      Project ID
        ``gyb-project-haj-zu2-x36``
      Contact
        James
      Documentation
        `Got Your Back (GYB) <https://github.com/GAM-team/got-your-back>`__
      Configuration
        ``~/bin/gyb/`` directory (``--config-folder`` to override)
      APIs
        See `Enabled APIs & services <https://console.cloud.google.com/apis/dashboard?project=gyb-project-haj-zu2-x36>`__
      Credentials
        -  ``GYB`` for ``gyb`` commands
        -  ``gyb-project-haj-zu2-x36@gyb-project-haj-zu2-x36.iam.gserviceaccount.com`` for ``gyb`` commands
        -  `Domain-wide Delegation <https://admin.google.com/ac/owl/domainwidedelegation>`__

   .. tab-item:: Library

      Project ID
        ``ocp-library``
      Contact
        James
      Documentation
        The New York Times `Library <https://github.com/nytimes/library#development-workflow>`__
      Configuration
        Heroku `settings <https://dashboard.heroku.com/apps/ocp-library/settings>`__
      APIs
        -  Google Drive API
      Credentials
        -  ``library`` to use Sign in with Google
        -  ``cloud-datastore-user@ocp-library.iam.gserviceaccount.com`` to use APIs in `nytimes/library <https://github.com/nytimes/library>`__

   .. tab-item:: Pelican

      Project ID
        ``pelican-289615``
      Contact
        James
      Documentation
        `Pelican <https://ocdsdeploy.readthedocs.io/en/latest/use/pelican.html#read-and-export-a-report>`__
      Configuration
        ``pelican-289615`` in `deploy <https://github.com/open-contracting/deploy>`__ and `deploy-pillar-private <https://github.com/open-contracting/deploy-pillar-private>`__
      APIs
        -  Google Docs API
        -  Google Drive API
      Credentials
        -  ``pelican@pelican-289615.iam.gserviceaccount.com`` to use APIs in `pelican-frontend <https://github.com/open-contracting/pelican-frontend/blob/main/exporter/gdocs.py>`__

Troubleshoot
------------

If an administrator lacks access to a project, run, for example:

.. code-block:: bash

   gcloud projects add-iam-policy-binding ocds-172716 --member user:jmckinney@open-contracting.org --role roles/owner

If the user interface lacks access to an organization, run, for example:

.. code-block:: bash

   gcloud organizations add-iam-policy-binding organizations/1015889055088 --member domain:open-contracting.org --role roles/recommender.viewer

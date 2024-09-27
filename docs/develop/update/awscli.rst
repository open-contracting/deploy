Configure AWS CLI
=================

.. hint::

   AWS CLI is the `Amazon Web Services Command Line Interface <https://aws.amazon.com/cli/>`__.

#. :ref:`Create an IAM backup policy and user<aws-iam-backup-policy>`
#. In the server's private Pillar file, add the *Access key ID* and *Secret access key*, for example:

.. code-block:: yaml

   aws:
     access_key: AKIAIOSFODNN7EXAMPLE
     secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
     region: us-east-1

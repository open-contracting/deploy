Configure AWS Command Line Interface
====================================

The AWS Command Line Interface (AWS CLI) is used by the site file and MySQL backup scripts.

Configure Pillar
----------------

In the service's Pillar file, add the following, replacing the example keys:

.. code-block:: yaml

   aws:
     access_key: AKIAIOSFODNN7EXAMPLE
     secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
     region: us-east-1

Configure maintenance
=====================

Enable maintenance with:

.. code-block:: yaml

   maintenance:
     enabled: True

This enables the ``rhunter`` state and is a condition for the below states.

.. note:: The default in ``pillar/common.sls`` is ``False`` (disabled).

rkhunter
--------

`rkhunter <https://en.wikipedia.org/wiki/Rkhunter>`__ requires configuration to avoid false positives. For example:

.. code-block:: yaml

   maintenance:
     rkhunter_customisation: |
       ALLOWHIDDENDIR=/etc/.java
       ALLOWDEVFILE=/dev/shm/PostgreSQL.*

Patching
--------

Set ``maintenance.patching`` to ``automatic`` on development servers and ``manual`` on production servers.

.. code-block:: yaml

   maintenance:
     patching: manual

.. note:: The default in ``pillar/common.sls`` is ``automatic``.

Hardware sensors
----------------

.. important:: Hardware servers only

After deploying the server:

#. Connect to the server as the ``root`` user
#. Detect sensors with:

   .. code-block:: bash

      sensors-detect

#. Update the server's Pillar file, for example:

   .. code-block:: yaml

      maintenance:
        hardware_sensors: True
        custom_sensors:
          - coretemp
          - nct6775

#. :doc:`Deploy the server<../../deploy/deploy>`

RAID monitoring
---------------

If the server uses a hardware RAID controller:

#. Install RAID monitoring software
#. Add a script under ``salt/maintenance/raid_monitoring/files/``
#. Add to the server's Pillar file, for example:

   .. code-block:: yaml

      maintenance:
        raid_monitoring_script: adaptec_raidcheck.sh

If the server uses a software RAID controller:

#. Check that mdadm is running:

   .. code-block:: shell-session

      $ ps aux | grep mdadm
      root       648  0.0  0.0   7552  1972 ?        Ss   Jul17   0:02 /sbin/mdadm --monitor --scan

#. Check that mdam is configured to send emails to root:

   .. code-block:: shell-session

      $ grep MAILADDR /etc/mdadm/mdadm.conf
      MAILADDR root

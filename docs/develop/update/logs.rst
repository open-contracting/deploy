Configure rsyslog and logrotate
===============================

rsyslog
-------

To add an rsyslog configuration file:

#. Add a configuration file to ``salt/core/rsyslog/files``
#. Add a mapping to the server's Pillar file

For example:

.. code-block:: yaml

   rsyslog:
     conf:
       91-kingfisher-summarize.conf: kingfisher-summarize.conf

The ``kingfisher-summarize.conf`` file in ``salt/core/rsyslog/files`` will be written to ``/etc/rsyslog.d/91-kingfisher-summarize.conf``, and the ``rsyslog`` service will be restarted.

.. tip::

   To discard a message after writing it to a `regular file <https://www.rsyslog.com/doc/configuration/actions.html#regular-file>`__, add `& stop <https://www.rsyslog.com/doc/configuration/actions.html#discard-stop>`__ as a second action on a new line.

logrotate
---------

#. Add a configuration file to ``salt/core/logrotate/files``
#. Add a mapping to the server's Pillar file

For example:

.. code-block:: yaml

   logrotate:
     conf:
       kingfisher-summarize:
         source: kingfisher-summarize
         context:
           mykey: myvalue

The ``kingfisher-summarize`` file in ``salt/core/logrotate/files`` will be written to ``/etc/logrotate.d/kingfisher-summarize``.

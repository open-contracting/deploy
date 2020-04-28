Kingfisher Process
==================

Read the `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__ documentation, which cover general usage.

View Logs
---------

The logs from Process are available for the ``ocdskfs`` and ``ocdskfp`` users to read.

The newest logs are at ``/var/log/kingfisher.log``.

Log rotation is used, and older logs can be found at ``/var/log/kingfisher.log.1`` and other compressed files like ``/var/log/kingfisher.log.2.gz``.

Logs are tagged with a logger, and you can use this to filter for events you want to see.

* Run ``grep  ocdskingfisher.checks  /var/log/kingfisher.log  | less`` to see which collections the system is running checks on.
* Run ``grep  ocdskingfisher.web  /var/log/kingfisher.log  | less`` to see calls made to the process system by a crawl.


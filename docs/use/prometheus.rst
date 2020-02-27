Prometheus
==========

Monitor
-------

Access the `monitoring service <http://monitor.prometheus.open-contracting.org>`__. The username is ``prom``. The password is set by the ``prometheus.server_password`` variable in the ``pillar/private/prometheus_pillar.sls`` file.

The landing page lets you query the collected data. For example:

* `Load averages <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=node_load15%20%2F%20count(count(node_cpu_seconds_total)%20without%20(mode))%20without%20(cpu)&g0.tab=0>`__
* `Blocked processes <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=node_procs_blocked&g0.tab=0>`__
* `Disk usage  <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=1%20-%20node_filesystem_avail_bytes%20%2F%20node_filesystem_size_bytes%20%7Bmountpoint%20!~%20%22%2F(boot%7Crun).*%22%7D&g0.tab=0>`__
* `Disk I/O <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=SUM(%7B__name__%3D~%22node_disk_io.*%22%7D)%20without%20(device)&g0.tab=0>`__
* `I/O wait <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=SUM(node_cpu_seconds_total%7Bmode%3D%22iowait%22%7D)%20without%20(cpu)&g0.tab=0>`__
* `RAM usage <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=1%20-%20node_memory_MemAvailable_bytes%20%2F%20node_memory_MemTotal_bytes&g0.tab=0>`__
* `Swap usage  <https://monitor.prometheus.open-contracting.org/graph?g0.range_input=8w&g0.stacked=0&g0.expr=node_memory_SwapCached_bytes%20%2F%20node_memory_SwapTotal_bytes&g0.tab=0>`__

Other relevant pages are:

* `Alerts <https://monitor.prometheus.open-contracting.org/alerts>`__
* `Targets <https://monitor.prometheus.open-contracting.org/targets>`__

Read `Prometheus' documentation <https://prometheus.io/docs/introduction/overview/>`__ to learn more.

Alert manager
-------------

Access the `alerting service <http://alertmanager.prometheus.open-contracting.org>`__.  The username is ``prom``. The password is set by the ``prometheus.alertmanager_password`` variable in the ``pillar/private/prometheus_pillar.sls`` file.

Whereas the monitoring service configures alerts, the alerting service sends alerts. Alerts are sent to the recipients set in ``salt/private/prometheus-server-alertmanager/conf-alertmanager.yml``.

You can temporarily "silence" alerts, when you know your actions will trigger those alerts: for example, when shutting down a server.

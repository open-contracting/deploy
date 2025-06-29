Prometheus
==========

Grafana
-------

Access the `monitoring dashboard <https://grafana.prometheus.open-contracting.org/>`__. The username is ``viewer``. The password is set by the ``apache.site.grafana.htpasswd.password`` variable in the ``pillar/private/prometheus_server.sls`` file.

These dashboards let you query system information in an interactive visual display, including: CPU, RAM, disk and network usage:

* `Server Monitoring Dashboard <https://grafana.prometheus.open-contracting.org/d/1864308e-eb04-4ded-bbea-c6188e502f11/server-monitoring-dashboard>`__
* `Prometheus System <https://grafana.prometheus.open-contracting.org/d/000000001/prometheus-system>`__

Monitor
-------

Access the `monitoring service <https://monitor.prometheus.open-contracting.org>`__. The username is ``prom``. The password is set by the ``apache.sites.prometheus-server.htpasswd.password`` variable in the ``pillar/private/prometheus_server.sls`` file.

The landing page lets you query the collected data. For example:

* Dashboard: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_memory_MemAvailable_bytes%20%2F%20node_memory_MemTotal_bytes&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w&g1.expr=node_memory_SwapCached_bytes%20%2F%201024%20%2F%201024&g1.tab=0&g1.stacked=0&g1.show_exemplars=0&g1.range_input=8w&g2.expr=node_load15%20%2F%20count(count(node_cpu_seconds_total)%20without%20(mode))%20without%20(cpu)&g2.tab=0&g2.stacked=0&g2.show_exemplars=0&g2.range_input=8w&g3.expr=1%20-%20node_filesystem_avail_bytes%20%2F%20node_filesystem_size_bytes%20%7Bmountpoint%3D%22%2F%22%7D&g3.tab=0&g3.stacked=0&g3.show_exemplars=0&g3.range_input=8w&g4.expr=(avg%20by(instance)%20(rate(node_disk_io_time_seconds_total%5B10m%5D)))%20*%20100&g4.tab=0&g4.stacked=0&g4.show_exemplars=0&g4.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_memory_MemAvailable_bytes%20%2F%20node_memory_MemTotal_bytes&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d&g1.expr=node_memory_SwapCached_bytes%20%2F%201024%20%2F%201024&g1.tab=0&g1.stacked=0&g1.show_exemplars=0&g1.range_input=1d&g2.expr=node_load15%20%2F%20count(count(node_cpu_seconds_total)%20without%20(mode))%20without%20(cpu)&g2.tab=0&g2.stacked=0&g2.show_exemplars=0&g2.range_input=1d&g3.expr=1%20-%20node_filesystem_avail_bytes%20%2F%20node_filesystem_size_bytes%20%7Bmountpoint%3D%22%2F%22%7D&g3.tab=0&g3.stacked=0&g3.show_exemplars=0&g3.range_input=1d&g4.expr=(avg%20by(instance)%20(rate(node_disk_io_time_seconds_total%5B10m%5D)))%20*%20100&g4.tab=0&g4.stacked=0&g4.show_exemplars=0&g4.range_input=1d>`__
* RAM usage: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_memory_MemAvailable_bytes%20%2F%20node_memory_MemTotal_bytes&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_memory_MemAvailable_bytes%20%2F%20node_memory_MemTotal_bytes&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Swap usage: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_memory_SwapCached_bytes%20%2F%201024%20%2F%201024&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_memory_SwapCached_bytes%20%2F%201024%20%2F%201024&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Load averages: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_load15%20%2F%20count(count(node_cpu_seconds_total)%20without%20(mode))%20without%20(cpu)&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_load15%20%2F%20count(count(node_cpu_seconds_total)%20without%20(mode))%20without%20(cpu)&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Blocked processes: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_procs_blocked&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=node_procs_blocked&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Disk usage : `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_filesystem_avail_bytes%20%2F%20node_filesystem_size_bytes%20%7Bmountpoint%3D%22%2F%22%7D&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=1%20-%20node_filesystem_avail_bytes%20%2F%20node_filesystem_size_bytes%20%7Bmountpoint%3D%22%2F%22%7D&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Disk I/O: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=(avg%20by(instance)%20(rate(node_disk_io_time_seconds_total%5B10m%5D)))%20*%20100&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=(avg%20by(instance)%20(rate(node_disk_io_time_seconds_total%5B10m%5D)))%20*%20100&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* I/O wait: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=(avg%20by(instance)%20(rate(node_cpu_seconds_total%7Bmode%3D%22iowait%22%7D%5B10m%5D)))%20*%20100&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=(avg%20by(instance)%20(rate(node_cpu_seconds_total%7Bmode%3D%22iowait%22%7D%5B10m%5D)))%20*%20100&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__
* Disk wear: `8-week <https://monitor.prometheus.open-contracting.org/graph?g0.expr=smartmon_wear_leveling_count_value&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=8w>`__, `1-day <https://monitor.prometheus.open-contracting.org/graph?g0.expr=smartmon_wear_leveling_count_value&g0.tab=0&g0.stacked=0&g0.show_exemplars=0&g0.range_input=1d>`__

Other relevant pages are:

* `Alerts <https://monitor.prometheus.open-contracting.org/alerts>`__
* `Targets <https://monitor.prometheus.open-contracting.org/targets>`__ (check "Unhealthy" targets)

Read `Prometheus' documentation <https://prometheus.io/docs/introduction/overview/>`__ to learn more.

Alert manager
-------------

Access the `alerting service <https://alertmanager.prometheus.open-contracting.org>`__.  The username is ``prom``. The password is set by the ``apache.sites.prometheus-alertmanager.htpasswd.password`` variable in the ``pillar/private/prometheus_server.sls`` file.

Whereas the monitoring service configures alerts, the alerting service sends alerts. Alerts are sent to the recipients set in ``salt/prometheus/alertmanager/files/config/conf-alertmanager.yml``.

You can temporarily "silence" alerts, when you know your actions will trigger those alerts: for example, when shutting down a server.

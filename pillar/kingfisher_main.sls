network:
  host_id: ocp23
  ipv4: 65.109.102.188
  ipv6: 2a01:4f9:3080:2792::2
  netplan:
    template: custom
    configuration: |
      network:
        version: 2
        renderer: networkd
        ethernets:
          enp6s0:
            addresses:
              - 65.109.102.188/32
              - 2a01:4f9:3080:2792::2/64
            routes:
              - on-link: true
                to: 0.0.0.0/0
                via: 65.109.102.129
              - to: default
                via: fe80::1
            nameservers:
              addresses:
                - 185.12.64.1
                - 2a01:4ff:ff00::add:1
                - 185.12.64.2
                - 2a01:4ff:ff00::add:2
                - 1.1.1.1
                - 2606:4700:4700::1111
                - 208.67.222.222
                - 2620:119:35::35

# Linux and PostgreSQL user names must match. PostgreSQL users should be in the kingfisher_process_read
# and kingfisher_summarize_read groups.
users:
  ahazin:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1zsfXvo9TTdF1YCMCtbvqIAMAtMHMSM+dTC/NYz+4rUF7hUMbTWbNaiezL35YVL2Fuwlerc82z7ktNyTYGtZTrtGdYa4MH/qtBXlHxdRrRz9bbza8DXcrSAEVosbGLe9m7eQMRfqh75m6tag/wXppx12f71K542Qm+/oJs83euHjP7urQa0Z7i9t0vjDqWw/JV39rpPx6F/GrplisyTokoXwVaoXXV9j3/ecBvYrzTI0v81OM7uiKegido4F2IC9xP6QHLuYNiYpYan+qZ/PwGfuMRrKtVof4d6xuJUlNoUKDx8VQGejMrTnTJnmuhdMZUCQ/nAJDfugDkFRpINyDAjt8E7jexLyIQVnqAYwAoIULKDB+Rp8vttSVBZVw0lTVjnopb+bIUE0sTAg3qeN0CDZAfjl/aMt7yFcF2LiZWLb9r+A9eoGo//q14VKD7ztKVQZavdqzR8oSVFwqFbz3+hziMPOl+83j3Mh3G6Rq9+QC3n7IfG/9sU/kk1kNHKU= Andrii (OCP)
  cmaudry:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFxAriOXxJGDnq1Qlia8AEE5bYzrzStfIAtE9iEer54RnXJVieE4E69eBcj7HqDIvCcav54PTamYp3J59XsoA0POynv+VSmaYxrFWF5aMKoirFpt1/wM98c7BMieE2158tsdwr/lRtkVYtAhWvk/Pol5A07cwJ5Ljd62Bud47B/ZsRSJTYDpH9N1VSeRigq6puH5KAExqz1L1EHluess2XhLUMUUB7agw7COzdj2jVj2jYZ8GIpuJ+A1TlzY4SNmR67W2CfZ3W8eO+fg9V6QeG0ldORuJlMw/XSpYcWqLBhLPR4rg7sYeob2Ld67GOYAUD7ccrW6J5CKpz5UXjZsFWn5AoDu7Qg5vQXLZoQYBGC0PSUY0YlpVrdiFjxy4JNRXFn81buAm14q7EYPZJ8VKS89t0EbVO6mB8trfYeALNGZwEAi8ba/3G8m+R84BuFuiLMDiWCC5IqbsRySmFmzTYDwoe3YPmA2+YcflkXiItOf+sMhjNeobBCBRyGWhCYADRjRImUpj5HZjaaEph2Nlt05EdTJvkdvY6C3XyyiE8y93dEva5c3T9jsIgYBfek7rtTrxN9dslhesimZGA0CjPB1FwbkQc+TBRSQ/1qPMDJvH690zpZrZIFluSux1pWcBKzdy0JFMeNQmOMPZ20mmccFKNvNS/HAzq7EC5h9TZvQ== colin@maudry.com
  csalazar:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJs4s1TkcqJg7RsjrpWib7UzHbUYIwnvr+8uK2r4wnZugoj4354jGTSlFlOGc5EQ4FkkNXIOUyOB0i1xxr8piC3VbapkEj/WfMSuElpGdWip3p/UonuNOAxheKna9SqdUvX+Yge/a/M5ElkBoQVZVng5n37e3mU70iveL4VqUzLqqXIY+lzcMlR3VBbuae1O+/T4ug2Teq2B3xL3uiuR+WYlGH9dZLapb+INiohtFImIBcVizdmRtKZRhKfAsh0h2mVp4mfJajz3LHcYkum1c0NvapgmxKIKyR8S2c6QB5jZjrldAFeHV/1mKF99KcmRf89JwkAnbbFT4+Zjks2g8P Camila (OCP)
  fpenna:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFAE0b54wyBl+LjxjgG28K2HBjDK5XmdKtV2S/swdiAYZKZZlsTzKWlmevWsK7kmF6HfJK8yTCxNmPJgdJ56ZBzKB38zwvh+EGrysKMJuHyW9aonpB4Ov9mTWVP8W8lRtYW0D+xzcPHxGqBZY3nWt/Vn5G/NVCbAODgn4qGerxqJWmHW79E7a0hLjqaijp29ykPqmOG8VD/07NCHCNgyAaB7jpZpNvpxcgfPsaJy/Nj+gvyksX72ip/d+vZyp2R3rkJIHXBZJdhDq9Z4gCxnURO0zGRqQTemG2JZ9tRws/0/QYy5UQbLaiDdkRSt1AIEYlHJ6BdbT+HpWOA0FBW1T+DKct9ECJhfBEJ0fn3sQPkNRvdRvtsujaqLPRyq1nTtNreWQbDwA1Qf1UR0/3dSon8APsVRt3goDfmDxsWEdDpCHpGQFNPui1oX8mVMejAgAg6e34KvzMnPqJSG7Rfq3QZpVkfNUOric54KcD7pdEse8IQuvR/xvaDda1szNOZOM= Félix (OCP)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDQHuw4wkhLviTG8TmsEW5I28nyEH091wpu4DGGgDAO4zvoOQU+jRjHAn0EVNmCqLUudIA22EIxofHklRedLDYFXFtTEewa6JdKZhCci+njxrObUwxeD/EJhAWS7mUAIhIZx73UdH2ZRLz11njiRT/9w6RzIDr+YkomQwtxKB0KPTr70HNtShM20V934WbkEe90cV5NLjcG9DqjxsgCTV3HVnJ3Ev/51TGmkfMdwyPR7BluADZUYRaMl/FVBlbBzvKgnjannx875Xc7ORJ9WG+WR2jCApZ6pr1pY4TFC1z+X3w0Ji9UftKMXely/qsehGeEywLpbtkdjsGD2O6uGhgSNbubKgFIUAu74YAWlwq+UQS56L6Y2L/Z1vAlC2NktR6kZmTI5NvbcaFXnn5QTapaeVznvqUXyFpeNxylIROhVqdcP+coBhyhDJg4voRs8IaWyRfcKQ6i5abRcPRSxuh/SZxzv3as58hNZEgDH2U4xdwIQiBzv7OOHAUwKCT1QqJlNwJji7k0yZ5yoyw1j02IgXXQ+7CUJbVsK+MTzslDBiSF6spJK/HXZ4UBYGkz8pxy2jZffS24a5TCOqSZHmLFkgof78y2RopYp2JdNFeiL6g1jkYopficPTcpSYfQF1PkYYZBvucnLoPTqptirP6PazD27j2i23f461WQyx26lQ== Félix (OCP)
  jmckinney:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2AYzfKIjwrhN7Jg3RrQKK/YJSVo1OSXadbhgE8mKMLi5nuDN6v9g8+QodcCEdA/AjGIr25CtBWcLwvT33h0SfMZ9a8Csq2pv6IAQkigxMrr8aBE9TL8pqQuwcc7CS9PQNYFuqpKoC4PSvNGqn9NRPtZmPkmcIa+CL/G6Y48HY36jWsauI8T8l4gMeOkH9bfB1yNRmEwQAuA+PmGXgGSlx7Gj+TofOHNbWj1l7lThFyG73qQfqyMPmfHPIjyu1EfA4lBezjcgJXlE2VodrLTFfimORJLHk684xnmf7935KwmjBqIucD16PE/KSOyj+vQxXZCTLsQjDuXr3GexOJBXx James (OCP)
  uallakulov:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGq4JEQ2VpMGW5B8dpg3aRRLdfuc85dYBIDlLmXQJ7ef3/nsqF2gndwRp00sFqTZvPJzr//3p3okxauYkN7h9kegr2ALpueisHxNwaI+Rz6jHrwh3km0w0TAkQULt+n5vMNAjGG3oQkypu25x/WKkdwqc6CRMgMODUYMR6mkfaBLMnI0TT6P1AFHPdF+WqtuS40opaOeanhVhnIPdIajgxN99t2iCVTuAdC4odULs810wNphyQ5y1k4TUQEc5dyvCMdFrPZawUZ0rEHnaN4aPeAEI/zAVIiv0n91Yw2s8GEYW4iT5IbHJQs85DcCthjQb24cqpsH8TOz2aaLQzdH71OctU6HCKTWuercbKtPo7F+m1Ur0nGtK4uWFq/5tWkkHavwtOrz3NQneXl9LWz+MvFl5mN2vuHal493Vgk1LTqTTUF+4aNipmEh4NXg2fmufz+fx+Epx2JurPysmhSJaTUklwB6KtlrYFP7xZRw/5tPtO1g7Ti0qVQ/2M7h+yje0= Umrbek (OCP)
  ylisnichuk:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG8dhMVvgH/tt9+VoyokyUg/iKVcZKMku8pYN6o8RoT8XKoyP/iyrUIl5HxolqIt+PJTpomYkA40eJ/0mN4/kRhr+tctZ+tUdo8/G8H42FG3McklL6XlwOdXRGIYC+NynF8YGws57J8YkM2oL9linkUZYpGpVkNew2aEg916HWWfGZktwuQa7knIwIhFr9FlvxxaZhdcQ7VJjnJOP0fLLr5WCVaiWDGjQ5cHJURcTBL+j+eTRpKFvk9BMKCAQyLkSEluT0QeESDMtR7sRHA54to1LDXRX0ky9cAQ6mxXWgpSpmHCuPVYpzOfoSd7b8aczDLUGBxq9EWOTS3UMUWJBX Yohanna (OCP)

vm:
  # https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES
  nr_hugepages: 4300

ntp:
  - 0.fi.pool.ntp.org
  - 1.fi.pool.ntp.org
  - 2.fi.pool.ntp.org
  - 3.fi.pool.ntp.org

prometheus:
  node_exporter:
    smartmon: True

# rsyslog is needed as messages can be written by multiple processes.
# https://docs.python.org/3/howto/logging-cookbook.html#opening-the-same-log-file-multiple-times
rsyslog:
  conf:
    91-kingfisher-summarize.conf: kingfisher-summarize.conf

logrotate:
  conf:
    kingfisher-summarize.conf:
      source: kingfisher-summarize

cron:
  incremental:
    do_excluded_supplier.sh:
      identifier: DOMINICAN_REPUBLIC_EXCLUDED_SUPPLIER
      hour: 1
      minute: random

apache:
  public_access: True
  modules:
    mod_autoindex:
      enabled: True
    mod_md:
      MDMessageCmd: /opt/postgresql-certificates.sh
  sites:
    collect_generic:
      configuration: collect-generic
      servername: downloads.kingfisher.open-contracting.org
      context:
        documentroot: /home/collect_generic/data
    kingfisher-collect:
      configuration: proxy
      servername: collect.kingfisher.open-contracting.org
      context:
        documentroot: /home/collect/scrapyd
        proxypass: http://localhost:6800/
        authname: Kingfisher Scrapyd
    pelican_frontend:
      configuration: pelican
      servername: pelican.open-contracting.org
      context:
        # Need to sync with `docker_apps.pelican_frontend.port`.
        port: 8001
        static_port: 8004
        timeout: 300
    rabbitmq:
      configuration: rabbitmq
      servername: rabbitmq.kingfisher.open-contracting.org

postgres:
  version: 15
  # Public access allows Docker connections. Hetzner's firewall can be used to prevent non-local connections.
  public_access: True
  ssl:
    servername: postgres.kingfisher.open-contracting.org
  configuration:
    name: kingfisher-main1
    source: shared
    context:
      storage: ssd
      type: oltp
      # Kingfisher Process uses QuerySet.iterator() to not cache results at the QuerySet level.
      # https://docs.djangoproject.com/en/4.2/ref/models/querysets/#django.db.models.query.QuerySet.iterator
      #
      # With PostgreSQL, iterator() uses server-side cursors to stream results (and not load all at once).
      # It caches chunk_size results (default 2000) at the database driver level.
      # https://docs.djangoproject.com/en/4.2/ref/models/querysets/#django.db.models.query.QuerySet.iterator
      #
      # However, with server-side cursors, PostgreSQL assumes only 10% of results are fetched.
      # Kingfisher Process always uses all results from iterator(), so we set cursor_tuple_fraction to 1.0.
      # https://docs.djangoproject.com/en/4.2/ref/databases/#server-side-cursors
      content: |
        # https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-CURSOR-TUPLE-FRACTION
        cursor_tuple_fraction = 1.0

        # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-MAX-WAL-SIZE
        # https://github.com/open-contracting/deploy/issues/158
        max_wal_size = 10GB

        # https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-WAL-KEEP-SEGMENTS
        # https://github.com/open-contracting/deploy/issues/158
        wal_keep_size = 320
  backup:
    type: pgbackrest
    configuration: shared
    stanza: kingfisher-2023
    repo_path: /kingfisher

docker:
  user: deployer
  uid: 1005
  syslog_logging: True

kingfisher_collect:
  user: collect
  group: deployer
  autoremove: True
  summarystats: True
  context:
    bind_address: 0.0.0.0
  env:
    # Need to sync with `kingfisher_collect.user` and the `directory` Jinja variable in the kingfisher/collect/init.sls file.
    FILES_STORE: /home/collect/scrapyd/data
    RABBIT_EXCHANGE_NAME: &KINGFISHER_PROCESS_RABBIT_EXCHANGE_NAME kingfisher_process_data_support_production
    # Need to sync as `{RABBIT_EXCHANGE_NAME}_api`.
    RABBIT_ROUTING_KEY: kingfisher_process_data_support_production_api
    # Need to sync with `docker_apps.kingfisher_process.port`.
    KINGFISHER_API2_URL: http://localhost:8000

python_apps:
  kingfisher_collect:
    user: incremental
    git:
      url: https://github.com/open-contracting/kingfisher-collect.git
      branch: main
      target: kingfisher-collect
    # Do not set `cardinal: False`. Instead, remove `cardinal: True`.
    crawls:
      # - identifier: DOMINICAN_REPUBLIC
      #   spider: dominican_republic_api
      #   crawl_time: '2023-07-13'
      #   # The publication sets "version": "1.4".
      #   spider_arguments: -a compile_releases=true -a force_version=1.1 -a ignore_version=true
      #   cardinal: True
      #   users:
      #     - dgcp
      - identifier: ECUADOR
        spider: ecuador_sercop_bulk
        crawl_time: '2015-01-01'
        cardinal: True
        proxy: True
      - identifier: RWANDA
        spider: rwanda_api
        crawl_time: '2025-08-22'
        spider_arguments: -a compile_releases=true
      # - identifier: MOLDOVA
      #   spider: moldova
      #   crawl_time: '2021-06-11'
  kingfisher_summarize:
    user: summarize
    git:
      url: https://github.com/open-contracting/kingfisher-summarize.git
      branch: main
      target: kingfisher-summarize
    config:
      # Need to sync with the kingfisher/summarize/files/.env file.
      kingfisher-summarize/logging.json: salt://kingfisher/summarize/files/logging.json
  collect_generic:
    user: collect_generic
    git:
      url: https://github.com/open-contracting/collect-generic.git
      branch: main
      target: collect-generic

docker_apps:
  kingfisher_process:
    target: kingfisher-process
    port: 8000
    env:
      LOCAL_ACCESS: True
      ALLOWED_HOSTS: '*'
      RABBIT_EXCHANGE_NAME: *KINGFISHER_PROCESS_RABBIT_EXCHANGE_NAME
      SCRAPYD_URL: http://host.docker.internal:6800
      # This is set to be the same size as the prefetch_count argument.
      # https://ocdsextensionregistry.readthedocs.io/en/latest/changelog.html
      REQUESTS_POOL_MAXSIZE: 20
      ENABLE_CHECKER: True
  pelican_backend:
    target: pelican-backend
    filter: True
    env:
      RABBIT_EXCHANGE_NAME: &PELICAN_BACKEND_RABBIT_EXCHANGE_NAME pelican_backend_data_support_production
      # 2021-10-27: on kingfisher-main, out of 6.12318e+07 data items, 195009 or 0.3% are over 30 kB.
      KINGFISHER_PROCESS_MAX_SIZE: 30000
  pelican_frontend:
    target: pelican-frontend
    site: pelican_frontend
    port: 8001
    host_dir: /data/storage/pelican-frontend
    reports: True
    env:
      DJANGO_PROXY: True
      ALLOWED_HOSTS: pelican.open-contracting.org
      SECURE_HSTS_SECONDS: 31536000
      CORS_ALLOWED_ORIGINS: https://pelican.open-contracting.org
      RABBIT_EXCHANGE_NAME: *PELICAN_BACKEND_RABBIT_EXCHANGE_NAME
      GOOGLE_DRIVE_USER: pelican@pelican-289615.iam.gserviceaccount.com
      # Avoid warning: "Matplotlib created a temporary config/cache directory at /.config/matplotlib because the
      # default path (/tmp/matplotlib-........) is not a writable directory; it is highly recommended to set the
      # MPLCONFIGDIR environment variable to a writable directory, in particular to speed up the import of Matplotlib
      # and to better support multiprocessing."
      MPLCONFIGDIR: /dev/shm/matplotlib

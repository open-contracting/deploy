ssh:
  kingfisher:
    # Open Contracting Partnership
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/etrZ2uWMPgeK9nOB1Q7y22aPyvcWprR2KlIW0MVFLusp1p6s9ZCsehcIbmLps3pYGqoswur1VSAyzxFmd78TWzwFsze6yAydfmN0Q5HM8ZNzpAM6gEd8HgwyX1rEH+1EpZVQ8iiBAebc9aAuUyufz8m4ElybWPvKwNGpTSI0i7eGBJuJ1lSL7mQrnHUaesxBw/38rHvmzO28yHrktn23fHClUOJ2tCCiFh+1mPgh6YTq0yqxtyLGH2F/qvIpzsKRMEoqQ2ETmaRnc8oVLFi7otSM2K7EV7DuKSFJW5FRv5EA67gDOcBHMxUhdg+5E+1WMPZYSyNasEvgAgseFw/JczPeVwjtV0zhTxRQrwrrIkm38lifz/wiUtj9gVb1SmOIOfepY2oxSNM9633Biy7bc5/c7nvvBRHmeHKXZy04bFC77K5pTwVK2eXM9xZE040WuGnhwkum12bJiMwgmF9mbzIHzNSQQ9KY0jqOg8Tc3OqrSv9k6T546TjfuBW2ozM= Andrii (OCP)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJs4s1TkcqJg7RsjrpWib7UzHbUYIwnvr+8uK2r4wnZugoj4354jGTSlFlOGc5EQ4FkkNXIOUyOB0i1xxr8piC3VbapkEj/WfMSuElpGdWip3p/UonuNOAxheKna9SqdUvX+Yge/a/M5ElkBoQVZVng5n37e3mU70iveL4VqUzLqqXIY+lzcMlR3VBbuae1O+/T4ug2Teq2B3xL3uiuR+WYlGH9dZLapb+INiohtFImIBcVizdmRtKZRhKfAsh0h2mVp4mfJajz3LHcYkum1c0NvapgmxKIKyR8S2c6QB5jZjrldAFeHV/1mKF99KcmRf89JwkAnbbFT4+Zjks2g8P Camila (OCP)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFAE0b54wyBl+LjxjgG28K2HBjDK5XmdKtV2S/swdiAYZKZZlsTzKWlmevWsK7kmF6HfJK8yTCxNmPJgdJ56ZBzKB38zwvh+EGrysKMJuHyW9aonpB4Ov9mTWVP8W8lRtYW0D+xzcPHxGqBZY3nWt/Vn5G/NVCbAODgn4qGerxqJWmHW79E7a0hLjqaijp29ykPqmOG8VD/07NCHCNgyAaB7jpZpNvpxcgfPsaJy/Nj+gvyksX72ip/d+vZyp2R3rkJIHXBZJdhDq9Z4gCxnURO0zGRqQTemG2JZ9tRws/0/QYy5UQbLaiDdkRSt1AIEYlHJ6BdbT+HpWOA0FBW1T+DKct9ECJhfBEJ0fn3sQPkNRvdRvtsujaqLPRyq1nTtNreWQbDwA1Qf1UR0/3dSon8APsVRt3goDfmDxsWEdDpCHpGQFNPui1oX8mVMejAgAg6e34KvzMnPqJSG7Rfq3QZpVkfNUOric54KcD7pdEse8IQuvR/xvaDda1szNOZOM= Félix (OCP)

vm:
  nr_hugepages: 16545

ntp:
  - 0.fi.pool.ntp.org
  - 1.fi.pool.ntp.org
  - 2.fi.pool.ntp.org
  - 3.fi.pool.ntp.org

prometheus:
  node_exporter:
    smartmon: True

rsyslog:
  conf:
    90-kingfisher.conf: kingfisher-process.conf
    91-kingfisher-views.conf: kingfisher-summarize.conf

logrotate:
  conf:
    kingfisher.conf: kingfisher-process
    kingfisher-views.conf: kingfisher-summarize

apache:
  public_access: True
  sites:
    ocdskingfisherscrape:
      configuration: proxy
      servername: collect.kingfisher.open-contracting.org
      context:
        documentroot: /home/ocdskfs/scrapyd
        proxypass: http://localhost:6800/
        authname: Kingfisher Scrapyd

postgres:
  # If the replica becomes unavailable, we can temporarily enable public access.
  # public_access: True
  version: 11
  configuration: kingfisher-process1
  storage: ssd
  type: oltp
  replica_ipv4:
    - 148.251.183.230
  replica_ipv6:
    - 2a01:4f8:211:de::2
  backup:
    configuration: kingfisher-process1
    process_max: 8
    cron: |
        MAILTO=root
        # Daily incremental backup
        15 05 * * 0-2,4-6 postgres pgbackrest backup --stanza=kingfisher
        # Weekly full backup
        15 05 * * 3 postgres pgbackrest backup --stanza=kingfisher --type=full 2>&1 | grep -v "unable to remove file.*We encountered an internal error\. Please try again\.\|expire command encountered 1 error.s., check the log file for details"

kingfisher_collect:
  user: ocdskfs
  autoremove: True
  summarystats: True
  env:
    KINGFISHER_API_URI: https://process.kingfisher.open-contracting.org
    KINGFISHER_API_LOCAL_DIRECTORY: /home/ocdskfs/scrapyd/data/

python_apps:
  kingfisher_collect:
    user: collect
    git:
      url: https://github.com/open-contracting/kingfisher-collect.git
      branch: main
      target: ocdskingfishercollect
  kingfisher_process:
    user: ocdskfp
    git:
      url: https://github.com/open-contracting/kingfisher-process.git
      branch: v1
      target: ocdskingfisherprocess
    config:
      ocdskingfisher-process/logging.json: salt://kingfisher/process/files/logging.json
      ocdskingfisher-process/config.ini: salt://kingfisher/process/files/config.ini
    apache:
      configuration: kingfisher-process
      servername: process.kingfisher.open-contracting.org
    uwsgi:
      configuration: kingfisher-process
      port: 5001
      limit-as: 2048 # https://github.com/open-contracting/kingfisher-collect/issues/154
      workers: 200
      cheaper: 10
      cheaper-overload: 30
      cheaper-busyness-multiplier: 60 # * cheaper-overload = 30mins before stopping workers
  kingfisher_summarize:
    user: ocdskfp
    git:
      url: https://github.com/open-contracting/kingfisher-summarize.git
      branch: main
      target: ocdskingfisherviews
    config:
      kingfisher-summarize/logging.json: salt://kingfisher/summarize/files/logging.json

network:
  host_id: ocp25
  ipv4: 5.75.247.51
  ipv6: 2a01:4f8:c012:3ea8::1

ssh:
  dreambi:
    # RBC Group
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoZGzw8p8LmhnNKZbGaTV+SCTTdblGKmcpgS8YYPJ/K Olexandr Korsikov

ntp:
  - 0.de.pool.ntp.org
  - 1.de.pool.ntp.org
  - 2.de.pool.ntp.org
  - 3.de.pool.ntp.org

backup:
  location: ocp-dreambi-backup/site
  directories:
    # Must match directory in dreambi/init.sls.
    /home/dreambi/public_html/:

nginx:
  public_access: True
  sites:
    bi.dream.gov.ua:
      include: dream-bi
      servername: bi.dream.gov.ua
      context:
        qliksense_app: bbd2ec1f-dbb4-4606-9e17-4fb23d87f4e9
        qliksense_ip: 159.69.67.60
        qlikauth_port: 3000
        user: dreambi

docker:
  user: deployer
  uid: 1002
  syslog_logging: True

docker_apps:
  qlikauth:
    target: qlikauth
    site: bi.dream.gov.ua
    volumes:
      - redis/data
      - redis/tmp
    env:
      # Must end with a "/".
      QLIK_PROXY_SERVICE: https://ocp15.open-contracting.org:4243/qps/prod/

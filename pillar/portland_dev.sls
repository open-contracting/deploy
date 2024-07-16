network:
  host_id: ocp26
  ipv4: 20.106.239.92

ssh:
  ocpadmin:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDqX+SbrMFR6POXY9CD86as5BEp6TZrRFlp21BTnM3zAaN+wYYejUOsPDFn4lbI4YBkgMduCu3u9VsITBK7eZQAGncbaBu5IMQh72VKprjUvpEgwIvYuljtuonOZjbaWF+q0J0jaZVcjchpGSobw9s8F7B4bRC6pnIqEweigYxgHDVw8vena0TAeMMOI2MIzLfHEDe+Pb6INybtFrWSScxYsjb+SR0CoAorlyXCmP17MVdQKw49vRj99E7NvzofqRbOPKDlulorncbwRMm3VXx2z0Cy/9d+hQELw4RR4aSSB1fhbbdcb/Ak9hmh0CbkgjSzE637S7/RfXLQsYE/NnOruZ2r/w+UsUCqfznAFEv8wWJJdiPUBcGVMWVywUTvTcMO9uix0aLiFTQZkI4r6Ub/ob+rGfMiDBb8/MsvaSOeytU4Pn0L4ZV0MDkiILRw06E2ZXpX9B1BrivsmPU5W+CR5YiWoQIfe20X4uAa1drQe4Gn+ziteysHcvp2sgLzMnIIyVkG6Wqjbgy1jfeDt661bZiuKnqKey00zL+SZyqtB0tGq7L4SvvGvu1qwlNu1pCB6ziuFqxERGbBjAllOd6KgYTMQ3Y4st4vJ7jP/hm3Au+LR6+eqjACUV49pKeHuhafmygvNll6E2bEhQpIFpgi+QxF9H2WuBA0ZOsYZRDF5Q== shakh@quintagroup.org
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCukBaCjxmjFNPIy9NI2yWCv7nfMOpUC258R8CPOtjm7uTdp36pCslm8PratM+yOKRb59OLRI45IrANaVXXYYqoRVKh3pjtUM3bpvwsQuD7s44Mu8/NDXmP1/x+93hk5jGd1/7EL5k0o7iDmhI6ClZ8276IxW9ovOpDsq1729JfPKb/Tg3bF6X5/eEeGSe6JfSXa3vzpjQDMDYgpAT4VPm4rDoIzlxAKV0KSYPb/YeZNPF+iZUks8qz0ifdyhWilAS7MnM5mvGTBgW7FBJ7LYM8I3enudKKMWE6egQB+6tHcbz5SxjdSn5kY9V3HaQlmZA05GqLEjFEh++Z61e5uo4R yshalenyk@fusion.office.quintagroup.com

ntp:
  - 0.us.pool.ntp.org
  - 1.us.pool.ntp.org
  - 2.us.pool.ntp.org
  - 3.us.pool.ntp.org

netdata:
  enabled: False

rsyslog:
  conf:
    80-docker.conf: docker.conf

logrotate:
  conf:
    docker:
      source: docker

apache:
  public_access: True
  sites:
    portland:
      configuration: default
      servername: portland-dev.open-contracting.org

docker:
  user: deployer
  syslog_logging: True

postgres:
  version: 16
  # Docker containers don't use localhost to connect to the host's PostgreSQL service. Public access is controlled using Azure's firewall.
  public_access: True
  configuration: False

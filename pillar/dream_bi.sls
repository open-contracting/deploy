network:
  host_id: ocp25
  ipv4: 5.75.247.51
  ipv6: 2a01:4f8:c012:3ea8::2

ssh:
  root:
    # RBC Group
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEoZGzw8p8LmhnNKZbGaTV+SCTTdblGKmcpgS8YYPJ/K Olexandr Korsikov

nginx:
  public_access: True
  sites:
    dream-bi:
      configuration: dream-bi
      servername: ocp25.open-contracting.org

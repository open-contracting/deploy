network:
  host_id: ocp18
  ipv4: 176.58.107.239
  ipv6: "2a01:7e00:e000:04d4::"
  networkd:
    template: linode
    gateway4: 176.58.107.1

apache:
  sites:
    cove:
      servername: review.standard.open-contracting.org

docker_apps:
  cove:
    image: cove-ocds
    env:
      ALLOWED_HOSTS: review.standard.open-contracting.org
      FATHOM_ANALYTICS_ID: PPQKEZDX

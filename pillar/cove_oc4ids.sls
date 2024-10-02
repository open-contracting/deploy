network:
  host_id: ocp17
  ipv4: 176.58.112.127
  ipv6: "2a01:7e00:e000:04c1::"
  networkd:
    template: linode
    gateway4: 176.58.112.1

apache:
  sites:
    cove:
      servername: review-oc4ids.standard.open-contracting.org

docker_apps:
  cove:
    image: cove-oc4ids
    env:
      ALLOWED_HOSTS: review-oc4ids.standard.open-contracting.org
      FATHOM_ANALYTICS_ID: UHUGOEOK
      MEMCACHED_URL: http://host.docker.internal:11211

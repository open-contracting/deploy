network:
  host_id: ocp17
  ipv4: 176.58.112.127
  ipv6: "2a01:7e00:e000:04c1::"
  networkd:
    template: linode
    gateway4: 176.58.112.1

python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-oc4ids.git
    django:
      env:
        ALLOWED_HOSTS: review-oc4ids.standard.open-contracting.org
        FATHOM_ANALYTICS_ID: UHUGOEOK
    apache:
      servername: review-oc4ids.standard.open-contracting.org
      context:
        assets_base_url: /infrastructure

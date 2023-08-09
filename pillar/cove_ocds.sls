network:
  host_id: ocp18
  ipv4: 176.58.107.239
  ipv6: "2a01:7e00:e000:04d4::"
  networkd:
    template: linode
    gateway4: 176.58.107.1

python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-ocds.git
    django:
      env:
        ALLOWED_HOSTS: review.standard.open-contracting.org
        FATHOM_ANALYTICS_ID: PPQKEZDX
        # HOTJAR_ID: 1501232
        # HOTJAR_SV: 6
        # HOTJAR_DATE_INFO: "4th March to 30th September 2020"
    apache:
      servername: review.standard.open-contracting.org

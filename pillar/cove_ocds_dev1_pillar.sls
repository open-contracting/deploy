apache:
  servername: cove.dev1.cove.opencontracting.uk0.bigv.io
  serveraliases: []
git:
  url: https://github.com/open-contracting/cove-ocds.git
  branch: master
django:
  app: cove_project
  env:
    ALLOWED_HOSTS: .cove.opencontracting.uk0.bigv.io
    VALIDATION_ERROR_LOCATIONS_LENGTH: "100"
    VALIDATION_ERROR_LOCATIONS_SAMPLE: "True"

apache:
  sites:
    credere:
      servername: credere.open-contracting.org

docker_apps:
  credere:
    env:
      ENVIRONMENT: production
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 30
      REMINDER_DAYS_BEFORE_EXPIRATION: 3
      REMINDER_DAYS_BEFORE_LAPSED: 3
      REMINDER_DAYS_BEFORE_LAPSED_FOR_EXTERNAL_ONBOARDING: 29
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      DAYS_TO_CHANGE_TO_LAPSED: 30
      DAYS_TO_ERASE_BORROWERS_DATA: 7
      # Email addresses
      OCP_EMAIL_GROUP: credereadmin@open-contracting.org
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      # Email templates
      FRONTEND_URL: https://credere.open-contracting.org
      BACKEND_URL: https://credere.open-contracting.org/api
      IMAGES_BASE_URL: https://cdn.credere.open-contracting.org/images
      # Data sources
      SECOP_DEFAULT_DAYS_FROM_ULTIMA_ACTUALIZACION: 1
    # NOTE: sla-overdue-applications is disabled as not useful.
    cron:
      - identifier: LAPSE_APPLICATIONS
        command: update-applications-to-lapsed
        hour: 1
      - identifier: REMOVE_LAPSED_APPLICATIONS
        command: remove-dated-application-data
        hour: 2

# Listed out-or-order for easier comparison with credere_dev.sls.
network:
  host_id: ocp24
  ipv4: 213.52.130.126
  ipv6: "2a01:7e00:e000:06e6::"
  networkd:
    template: linode
    gateway4: 213.52.130.1

docker:
  uid: 1000

postgres:
  configuration:
    context:
      ram_ratio: 0.75
      # Rounded down to a power of 2. https://postgresqlco.nf/doc/en/param/work_mem/
      work_mem: 8
  backup:
    type: pgbackrest
    configuration: shared
    stanza: credere
    repo_path: /credere

apache:
  sites:
    credere:
      servername: credere.open-contracting.org

docker_apps:
  credere_backend:
    target: credere-backend
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
      - identifier: FETCH_AWARDS
        command: fetch-awards
        hour: 14
      - identifier: REMIND_MSME
        command: send-reminders
        hour: 15
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
      # Rounded down to a power of 2.
      work_mem: 8
      content: |
        ### pgBackRest
        # https://pgbackrest.org/user-guide.html#quickstart/configure-archiving

        # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-LEVEL
        wal_level = logical

        # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-ARCHIVE-MODE
        archive_mode = on

        # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-ARCHIVE-COMMAND
        # https://pgbackrest.org/user-guide.html#async-archiving/async-archive-push
        archive_command = 'pgbackrest --stanza=credere archive-push %p'

        # https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-MAX-WAL-SENDERS
        max_wal_senders = 4
  backup:
    type: pgbackrest
    configuration: shared
    stanza: credere
    retention_full: 4
    repo_path: /credere
    process_max: 4

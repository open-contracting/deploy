network:
  host_id: ocp24
  ipv4: 213.52.130.126
  ipv6: "2a01:7e00:e000:06e6::"
  networkd:
    template: linode
    gateway4: 213.52.130.1

apache:
  sites:
    credere:
      servername: credere.open-contracting.org

docker:
  uid: 1000

docker_apps:
  credere_backend:
    target: credere-backend
    env:
      ENVIRONMENT: production
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 30
      REMINDER_DAYS_BEFORE_EXPIRATION: 3
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      DAYS_TO_CHANGE_TO_LAPSED: 30
      DAYS_TO_ERASE_BORROWERS_DATA: 7
      # Data sources
      SECOP_DEFAULT_DAYS_FROM_ULTIMA_ACTUALIZACION: 1
      # Email addresses
      OCP_EMAIL_GROUP: credereadmin@open-contracting.org
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      # Email templates
      FRONTEND_URL: https://credere.open-contracting.org
      BACKEND_URL: https://credere.open-contracting.org/api
      IMAGES_BASE_URL: https://cdn.credere.open-contracting.org/images
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

postgres:
  configuration:
    context:
      # Docker and Netdata use the most memory (about 1.35 GB), after PostgreSQL.
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
    cron: |
        MAILTO=root
        # Daily incremental backup
        15 05 * * 0-2,4-6 postgres pgbackrest backup --stanza=credere
        # Weekly full backup
        15 05 * * 3 postgres pgbackrest backup --stanza=credere --type=full 2>&1 | grep -v "unable to remove file.*We encountered an internal error\. Please try again\.\|expire command encountered 1 error.s., check the log file for details"

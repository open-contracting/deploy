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
      FRONTEND_URL: https://credere.open-contracting.org
      ENVIRONMENT: production
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      DAYS_TO_CHANGE_TO_LAPSED: 14
      DAYS_TO_ERASE_BORROWERS_DATA: 7
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      REMINDER_DAYS_BEFORE_EXPIRATION: 3
      SECOP_DEFAULT_DAYS_FROM_ULTIMA_ACTUALIZACION: 1
      # Email addresses
      TEST_MAIL_RECEIVER: credereadmin@open-contracting.org
      OCP_EMAIL_GROUP: credereadmin@open-contracting.org
      # Email templates
      LINK_LINK: https://credere.open-contracting.org
      IMAGES_BASE_URL: https://credere.open-contracting.org/images
    cron:
      - identifier: FETCH_AWARDS
        command: fetch-awards
        hour: 14
      - identifier: REMIND_MSME
        command: send-reminders
        hour: 15
      - identifier: REMIND_FI
        command: sla-overdue-applications
        hour: 13
      - identifier: LAPSE_APPLICATIONS
        command: update-applications-to-lapsed
        hour: 1
      - identifier: REMOVE_LAPSED_APPLICATIONS
        command: remove-dated-application-data
        hour: 2
      - identifier: UPDATE_STATISTICS
        command: update-statistics
        hour: 3

network:
  host_id: ocp22
  ipv4: 178.79.139.218
  ipv6: "2a01:7e00:e000:04e8::"
  networkd:
    template: linode
    gateway4: 178.79.139.1

apache:
  sites:
    credere:
      servername: dev.credere.open-contracting.org

docker:
  uid: 1000

docker_apps:
  credere_backend:
    target: credere-backend
    env:
      FRONTEND_URL: https://dev.credere.open-contracting.org
      ENVIRONMENT: development
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      DAYS_TO_CHANGE_TO_LAPSED: 1
      DAYS_TO_ERASE_BORROWERS_DATA: 1
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      REMINDER_DAYS_BEFORE_EXPIRATION: 2
      # Email addresses
      TEST_MAIL_RECEIVER: crederedev@open-contracting.org
      OCP_EMAIL_GROUP: ylisnichuk@open-contracting.org
      # Email templates
      LINK_LINK: https://dev.credere.open-contracting.org
      IMAGES_BASE_URL: https://dev.credere.open-contracting.org/images

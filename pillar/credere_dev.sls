apache:
  sites:
    credere:
      servername: dev.credere.open-contracting.org

docker_apps:
  credere_backend:
    target: credere-backend
    env:
      ENVIRONMENT: development
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      REMINDER_DAYS_BEFORE_EXPIRATION: 1
      REMINDER_DAYS_BEFORE_LAPSED: 1
      REMINDER_DAYS_BEFORE_LAPSED_FOR_EXTERNAL_ONBOARDING: 1
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      DAYS_TO_CHANGE_TO_LAPSED: 2
      DAYS_TO_ERASE_BORROWERS_DATA: 1
      # Email addresses
      OCP_EMAIL_GROUP: ylisnichuk@open-contracting.org
      TEST_MAIL_RECEIVER: crederedev@open-contracting.org
      # Email templates
      FRONTEND_URL: https://dev.credere.open-contracting.org
      BACKEND_URL: https://dev.credere.open-contracting.org/api
      IMAGES_BASE_URL: https://dev.credere.open-contracting.org/images

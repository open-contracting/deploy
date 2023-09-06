apache:
  sites:
    credere:
      servername: ocp24.open-contracting.org

docker_apps:
  credere_frontend:
    target: credere-frontend
    port: 8000
    env:
      # Vite
      VITE_API_URL: https://ocp24.open-contracting.org/api # https://credere.open-contracting.org/api
      VITE_HOST: ocp24.open-contracting.org # credere.open-contracting.org
  credere_backend:
    target: credere-backend
    port: 3000
    env:
      FRONTEND_URL: https://ocp24.open-contracting.org # https://credere.open-contracting.org
      ENVIRONMENT: production
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      DAYS_TO_CHANGE_TO_LAPSED: 14
      DAYS_TO_ERASE_BORROWERS_DATA: 7
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      REMINDER_DAYS_BEFORE_EXPIRATION: 3
      # Email templates
      LINK_LINK: https://ocp24.open-contracting.org # https://credere.open-contracting.org
      IMAGES_BASE_URL: https://ocp24.open-contracting.org/images # https://credere.open-contracting.org/images

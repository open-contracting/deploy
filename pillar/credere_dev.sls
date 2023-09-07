network:
  host_id: ocp22
  ipv4: 178.79.139.218
  ipv6: "2a01:7e00:e000:04e8::"
  networkd:
    template: linode
    gateway4: 178.79.139.1

ssh:
  root:
    # Codium
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU3ReQKWROE4X9VBjIsWukltiSRuGjgKzk9PxeeLLcZN2KBB/Ch+p3vQ/mKfFPyME/eMYs44yXONxFBwURT4KQNIj/aoSurJftVk5t0d3+IvdO+ewMRCtS6qs3Lm+YWCFEphEHLvZrRvBrWU61aISGRbN+HLTIIMvKFWz5u2XeiP4vuaPTOhnlQNPUYuaPS8OWRQ8cN5QBZF5sZ+1jHYpIuwn+ghxxy0qIy1caEjRcLC0dpa2Hc0cqyTTL+ukLzh0TC0lw6eHfrpmARoltFsQDiB9TQ1NroOXVbN+hv0CqJFRPk4W8NQX5CMmHBOyR1fdRFUDF7Eb3eVjU5mRYFoTQascCfNswS7+g2bJAHHVZAz32tyK5TdR25b2473NVRh+bds2CpAsG5sxF2lKhDYuyu/4Ye7322l5Titj3K8FaOKPIkLI4ADQ+qp9QoSaqMkVd8aTpMX0RbA4fcbkFaOZLO+/NeRGP4HL6djWCVT6dJMQp2z798lJo1Bo01HYwJDKwPTflf3shi/e8jubKdM/FWTblsrQSM7OWJ60vUYMdsChP93RyzClSyHvk785MV+rBtuVuwsCQnNSZ+q0YvQb/CdcNcBz0NJ0Z3DG+e5izCOsOWBGDGHeRqD3L22Lm0Lx/WxNIO1q59Nv1Q/wzI+I/WfWhlBYhYmjsfgLp9ZFBuQ== Adrian Martinez
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG+JzWnsjsGm2Wsq4DAAIMTt2/W9LdGpO3yTeCmtmvsC Hernan Lombardo
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9MGhSco1OfXD0Dh2YhZi9yMRjhflmnlqYoy6+0vlNAtxj3KZqC3xvWh7wM7yeNh+ThoiubFwrkLQ86VWRtbwJHn0Ih3IiegOdu8lsFVBWGwVPZ5cun6gIlE9yjp0WOfqnLKYjXfDgr4LPousJg6beQj9v29JlmEYzrj83ynxj8z1h3Aysfbvc6yE3Wt1w0tNNXJwOy0KEbrwdEWFAShrIk6yLYQ9ZkcPdMq/1/hYySvGBpQFiVpRaabnoPGzpzeqwc1N8vdcvk9aynAOnbcPQKXFClk3BtBd4w1acgFGzCe2wDaUfuInuCCtoKJ3KlL8ifWQUYyOuDNg6hHEQqq9f Nahuel Hernandez
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/gBo10diGp4nSNBg+BopnoRHCwzkzkTlGW69NpegUqMBiBrLGvcaST0jvqepbsTRyqkgJkll22yrP5yQG6Lc3zUN3BRWhGZmhGGY0soTHbCr1OE3d/JHne9wJYDV0FD9CRJPLgwjI/+dyTTLtKAOBd+uYY4yPtfs/FLlzrTt/Yo0CFjRASYY3mx8wpoy808pxrB2Ba5hk8OX3EF+LJXHZcDcliiKj0SpEyDWx3Bcy7Iz/PgwqJm10pZzuKetCbRsjig1pg5JFNs9Ydw1tEFEOYcOrzdspQ9bMilPlqtCV2gGa0cexOPlVaJzqr+BnNSgxPoZv9gG6u+iKSVBtPTKTAMRLqYpkW0XSFTfr+pl+fkxYONdsvenTipGnk8vahevEhjAmZqWCrAQPwptrXCkldBy52dU5hKFVxEhTRvxYmFzMYPP3b182WlDXmizgW0DZ5NU7U1gzT6wa1RQ/5q6xv72QT2oyaTaS/VgEyvcMA1FbiZllPRW+68eh6UevkbGNKj/BOH3z7e7FAhuDcvLoFxNzPKtRP7/49wXLgABYUXQ/ENp/YyMeF9j+VnNfSW2FhYfbYzDWPTGrecdaD3iD+h+IeTPvGsP65ykWkHOCjec/Mr3sgibPZKYWtcLzVaGFpbHG5QiVEOPgb3VVFkqUeYSMlbQPNMjyYZQ63wV5hw== Rodrigo Parra
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFdIQ2wSNmdk/nHvHSHUbnwYjP9JiyW5aBc5YWeBBc/b Fernando Cardozo

apache:
  sites:
    credere:
      servername: ocp22.open-contracting.org

docker_apps:
  credere_frontend:
    target: credere-frontend
    env:
      VITE_API_URL: https://ocp22.open-contracting.org/api
      VITE_HOST: ocp22.open-contracting.org # credere.open-contracting.org
  credere_backend:
    target: credere-backend
    env:
      FRONTEND_URL: https://ocp22.open-contracting.org
      ENVIRONMENT: development
      # Timeline
      APPLICATION_EXPIRATION_DAYS: 7
      DAYS_TO_CHANGE_TO_LAPSED: 1
      DAYS_TO_ERASE_BORROWERS_DATA: 1
      PROGRESS_TO_REMIND_STARTED_APPLICATIONS: 0.7
      REMINDER_DAYS_BEFORE_EXPIRATION: 2
      LINK_LINK: https://ocp22.open-contracting.org # https://credere.open-contracting.org
      IMAGES_BASE_URL: https://ocp22.open-contracting.org/images # https://credere.open-contracting.org/images

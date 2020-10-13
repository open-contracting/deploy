# Example django app configuration
# 

# App user.
user: exampleuser

# App directory.
# /home/$user/$app_dir
name: example_app

apache:
  servername: ex1.open-contracting.org
  https: both

git:
  url: https://github.com/open-contracting/example_django_app.git

django:
  app: example_app
  env:
    EXAMPLE=value

uwsgi:
  # Timeout in seconds per request (900 = 15 minutes).
  haraki: 900
  # Limit memory usage in MB.
  limit-as: 1024
  # Total requests before worker is restarted.
  # This helps address memory leaks.
  max-requests: 1024
  # Restart the worker if it finishes processing its request with 250MB or more in memory.
  reload-on-as: 250


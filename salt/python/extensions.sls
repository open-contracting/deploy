python c extensions:
  pkg.installed:
    - pkgs:
      - python3-dev
      - build-essential

{% if grains.osmajorrelease|string == '22' %}
# Required for cffi pip package install.
libffi-dev:
  pkg.installed:
    - name: libffi-dev
{% endif %}

{% from 'lib.sls' import set_config %}

awscli:
  pkg.installed:
    - name: python3-pip
    - install_recommends: False
  pip.installed:
    - name: awscli
{% if grains.osmajorrelease | int >= 24 %}
    # https://peps.python.org/pep-0668/
    - extra_args:
      - --break-system-packages
{% endif %}
    - require:
      - pkg: awscli

/home/sysadmin-tools/aws-settings.local:
  file.managed:
    - source: salt://aws/files/aws-settings.local
    - mode: 640
    - replace: False
    - require:
      - file: /home/sysadmin-tools/bin

{{ set_config('aws-settings.local', 'AWS_ACCESS_KEY_ID', pillar.aws.access_key) }}
{{ set_config('aws-settings.local', 'AWS_SECRET_ACCESS_KEY', pillar.aws.secret_key) }}
{{ set_config('aws-settings.local', 'AWS_DEFAULT_REGION', pillar.aws.region) }}

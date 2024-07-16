{% from 'lib.sls' import set_cron_env %}

{% for user, commands in pillar.cron|items %}
{{ set_cron_env(user, 'MAILTO', 'sysadmin@open-contracting.org', 'cron') }}

/home/{{ user }}/bin:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

{% for command, arguments in commands|items %}
/home/{{ user }}/bin/{{ command }}:
  file.managed:
    - source: salt://cron/files/{{ command }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - file: /home/{{ user }}/bin

add {{ arguments.identifier }} cron job in {{ user }} crontab:
  cron.present:
    - name: /home/{{ user }}/bin/{{ command }}
    - user: {{ user }}
  {% for argument, value in arguments|items %}
    - {{ argument }}: {{ value }}
  {% endfor %}
    - require:
      - user: {{ user }}_user_exists
{% endfor %}
{% endfor %}

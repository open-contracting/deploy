{% for user, commands in pillar.cron|items %}
/home/{{ user }}/bin:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

{% for command, arguments in commands.items() %}
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
    - user: {{ user }}
    - name: /home/{{ user }}/bin/{{ command }}
  {% for argument, value in arguments.items() %}
    - {{ argument }}: {{ value }}
  {% endfor %}
    - require:
      - user: {{ user }}_user_exists
{% endfor %}
{% endfor %}

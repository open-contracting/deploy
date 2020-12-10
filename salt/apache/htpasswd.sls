# http://docs.saltstack.cn/ref/states/all/salt.states.htpasswd.html
apache2-utils:
  pkg.installed

{% for user, entry in pillar.apache.htpasswd.items() %}
htpasswd-{{ user }}:
  webutil.user_exists:
    - name: {{ entry.name }}
    - password: {{ entry.password }}
    - htpasswd_file: /home/{{ user }}/htpasswd
    - runas: {{ user }}
    - update: True
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

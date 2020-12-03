apache2:
  pkg.installed:
    - name: apache2
  service.running:
    - name: apache2
    - enable: True
    - reload: True

{% if salt['pillar.get']('apache:htpasswd') %}
# http://docs.saltstack.cn/ref/states/all/salt.states.htpasswd.html
apache2-utils:
  pkg.installed

{% for entry in pillar.apache.htpasswd.values() %}
htpasswd-{{ entry.user }}:
  webutil.user_exists:
    - name: {{ entry.name }}
    - password: {{ entry.password }}
    - htpasswd_file: /home/{{ entry.user }}/htpasswd
    - runas: {{ entry.user }}
    - update: True
    - require:
      - user: {{ entry.user }}_user_exists
{% endfor %}
{% endif %}

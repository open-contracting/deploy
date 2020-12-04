apache2:
  pkg.installed:
    - name: apache2
  service.running:
    - name: apache2
    - enable: True
    - reload: True

{% if salt['pillar.get']('apache:htpasswd') %}
# To create an htpasswd file, add the following data to a Pillar file:
#
# apache:
#   htpasswd:
#     SYSTEM-USER:
#       name: NAME
#       password: PASSWORD

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
{% endif %}

# These are all non-essential changes for added usability on our systems.
{% set editor = '/usr/bin/vim.tiny' %}

useful commands for general purpose:
  pkg.installed:
    - pkgs:
      - curl
      - htop
      - iotop
      - man-db
      - psmisc # provides killall
      - ripgrep
      - tmux
      - unzip

vim:
  pkg.installed:
    - name: vim

# Set vim as the default editor now that we've installed it.
editor:
  cmd.run:
    - name: update-alternatives --set editor {{ editor }}
    - unless: test "$(readlink /etc/alternatives/editor)" = "{{ editor }}"
    - require:
      - pkg: vim

/etc/profile.d/99-history-timeformat.sh:
  file.append:
    - text: |
        export HISTTIMEFORMAT="%d/%m/%y %T "

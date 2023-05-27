# These are all non-essential changes for added usability on our systems.

useful commands for general purpose:
  pkg.installed:
    - pkgs:
      - curl
      - htop
      - iotop
      - man-db
      - psmisc # provides killall
      - tmux
      - unzip

vim:
  pkg.installed:
    - name: vim

# Set vim as the default editor now that we've installed it.
editor:
  alternatives.set:
    - path: /usr/bin/vim.basic
    - require:
      - pkg: vim

/etc/profile.d/99-history-timeformat.sh:
  file.append:
    - text: |
        export HISTTIMEFORMAT="%d/%m/%y %T "

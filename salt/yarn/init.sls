# https://classic.yarnpkg.com/en/docs/install/#debian-stable
yarn:
  pkgrepo.managed:
    - humanname: Yarn Official Repository
    - name: deb https://dl.yarnpkg.com/debian stable main
    - file: /etc/apt/sources.list.d/yarn.list
    - key_url: https://dl.yarnpkg.com/debian/pubkey.gpg
  pkg.installed:
    - name: yarn
    - require:
      - pkgrepo: yarn

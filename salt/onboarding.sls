# `order` is used, to ensure these states run before any core states.

update all packages:
  pkg.uptodate:
    - order: 1
    - refresh: True
    - dist_upgrade: True

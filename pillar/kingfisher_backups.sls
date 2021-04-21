postgres:
  backup:
    enabled: False
    identifier: kingfisher
    total_full_backups: 4
    process_max: 4
    s3_bucket: ocp-backup
    s3_endpoint: s3.eu-west-1.amazonaws.com
    region: eu-west-1
    repo_path: /kingfisher

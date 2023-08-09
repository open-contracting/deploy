network:
  host_id: ocp17
  ipv4: 176.58.112.127
  ipv6: "2a01:7e00:e000:04c1::"
  networkd:
    template: linode
    gateway4: 176.58.112.1

ssh:
  root:
    # Open Data Services Co-operative
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDoKwR6h5C5P2gdzWLggZOnNKfrsi5jJCIPbA6bDm/rg7hWZ/H07NIaJtQ5dvqEw9w58bznOl/b7+3x9sEGF7Clp0kvuHECjtz3G9nlJ5NlUSJhNAcYVMLLwL/LN2Zj+kMaFH0inrbM+WngQGURYUYGjxv1XfUkHFKS4SlD2sdhNQbx4hVcUqkDq6X7AzfReXMeHLUinFTwwYaNgFV+nOQ242vVWnsL6HtTSTIuO7aPx/SSI5+jZqKCDK9oHFhXo4lgNB6JpVcaDcS8gV763jNqfQxfJUr3gm/GB8gcp0cfqf8Bd3ftXINh/zJA8L4FN6oJEeELKjF1ZY6Y8/k53cwEdzBbogJ3DrlWs0uaCu/EGypdA48eyPTx6j+bQ9JiobF3EADaVB/3NgfgpEa/o4tmu5dUcOLxsepr1ftUxh0Q1yx2ucqP3RSp2GBMCW1ln3c14iGWoRQPczXuvphLQnDvajNo7YwjlZCAvwn6j36WTbe0KNxWm/he1WeXyR1XzBuS5liWMfqKIjmBEeZgr67KIt8zx4yp960/U08tnlYx7PEM3I8xqmIF6mz8n+Kl3UAT+HAgkd+poD59dcTBo6f5A9+9oAA5V2z+BX6WI1Kuf6TtEiFND0izzNCs6/lmooOlgociid0V5fYqTGDRVt8SWLVIBggDOdjIR7y0jRXniw== Ben (ODSC)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC57kxFKNfdj/TO+V1cKVlJkbkT3rYg9W0D0r4z+NJfDFTkCPBip2LAjoEJyW/Ru/PDZc9lhrVCZ/sQ99GvRFtC8v2SQNQtJDk6dYACwTrhimJUQMt0y/dJ+Svib9m4TyK4wjQJzZMJNeMeY42Fl1Is9/uL5Bj3noPIg7jv6Z6RW/Oi8uoIAEatliBAfH+5v8SUxqbizkYyzUIcvQ6c2nATKlPw6Y7E6udqWEFOi+bxPsEe25N8gk7d26O7/4TDQXLW1vVakvC3MX7KN6/FVpHbmoiMhZb/niG/ue9Kvgx8YwQN0/wMQByjaudyUfzBOYMBpmPI74/7BvFGLnCQi+4L Ben (ODSC)

python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-oc4ids.git
    django:
      env:
        ALLOWED_HOSTS: review-oc4ids.standard.open-contracting.org
        FATHOM_ANALYTICS_ID: UHUGOEOK
    apache:
      servername: review-oc4ids.standard.open-contracting.org
      context:
        assets_base_url: /infrastructure

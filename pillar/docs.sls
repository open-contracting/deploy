network:
  host_id: ocp19
  ipv4: 178.79.135.174
  ipv6: "2a01:7e00:e000:04d5::"
  networkd:
    template: linode
    gateway4: 178.79.135.1

ssh:
  docs:
    # Public key for salt/private/keys/docs_ci
    - no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYvnxKiBcHVLpAJl+eO4zghzvQlo3GmzLvpNItSz6fjsvWAxQRH7aAZSD4cbX+m13qT60qiw63o5rc2t0CF02CGa+Dru0+lTHjVZTxsmyg7PhIPlHmz55QPP2S69uD++VEjgLSWC1MwUlq1I/mU8hAvMNb5ESs7vciOgmRbcWOdFCdKYKj4Az6I8p1MUExUw/8NDRP2HUrN5SbeFJ+u9eJfJBYAJYSspFB3SOesSmx2RP+vB9AP+3YEaBLGYNe3Ev5sOyWbPvEpcqtrD1Zf1MVKJCOlnz9I1I+o3aZmJu1TRu3V16XVctBV0d+rUrkgVcx/KIfeeL6NGACaUrl1SlRAUMzPwv6jcwwcHLadBhk154RThR3IIAG44wRT8/FaHUkDgiSKhqGmsc1nVu+vNSZ+1nun5xFEu0357oc/zywylFKX7lzeT40nM3dd43mmhtZAE3NjLduBiJC3gB5TQkr+l+K1GjiGeUD1uXFhvkbm9DtdTrFHwciq2rkCM3pmsMrO6fgMkj/pQM5WEFpJH67aohHNqohUKDDiU/EHTGliT7LxHOtmvPX5AFXDviZIrTnlmAn2J3IXeos84m6A1I8raRh4yQC+Gfosp1EHvuE/6V9Th9IeSKLmqVLUgLdUs3IoWAMqw+Nj3f/Krr+jd9bGDDNSaquNwiFF2ccgTspqQ==

vm:
  swappiness: 1

apache:
  public_access: True
  modules:
    mod_autoindex:
      enabled: True
  sites:
    ocds-docs-live:
      configuration: docs
      servername: standard.open-contracting.org

elasticsearch:
  # This is to inform the installation of ReadOnlyREST – not to control the version of Elasticsearch to install.
  version: 8.19.5
  plugins:
    readonlyrest:
      version: 1.66.1_es8.19.5
      configuration: docs

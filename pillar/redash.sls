apache:
  public_access: True
  sites:
    redash:
      configuration: proxy
      servername: redash.open-contracting.org
      context:
        proxypass: http://localhost:9090/

docker:
  docker_compose:
    # 1.22.0 is used in https://github.com/getredash/setup/blob/cb47626b6823cbafac407b3e8991e97f53121f6e/setup.sh#L18
    version: 1.22.0
# To test from another server:
# env \
#   http_proxy=http://ocp19.open-contracting.org:8888 \
#   https_proxy=http://ocp19.open-contracting.org:8888 \
#   no_proxy=localhost,sentry.io \
#   curl -i https://www.example.com
tinyproxy:
  url: 'http://ocp28.open-contracting.org:8888'
  allow:
    # ocp23
    - '65.109.102.188'
    - '2a01:4f9:3080:2792::2'
    # ocp27
    - '37.27.62.45'
    - '2a01:4f9:3081:3001::2'

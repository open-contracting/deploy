# Values used on all servers. These may be overwritten.

maintenance:
  enabled: False
  # Set safe default.
  patching: automatic

system_contacts:
  # For system notifications.
  root: servers@robhooper.net
  # For cron jobs.
  cron_admin: sysadmin@open-contracting.org,servers@robhooper.net

network:
  domain: open-contracting.org

ssh:
  # Public keys of users with root access to all servers.
  admin:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP3d8ga3my0PNfNPmtx03GG30Cshz6TqjiiJhADapxsl94yxShjCZhXBNMTzuoP4eHDNueOa2IMEtdnjM8q843sNM12WuE7i1AL37TV2Lg+8rcrGs3I3DGH23l709KXDk5cK8HIX6W769VER1KIOmUY79VKldkDJk1dHYjSudx1Wb0ISO8NQIE2VfQyceK88l33NLll3753/g7uM/9ON5bIsdWD41ieecYy181Hay1I9rlezLBbCo2pMkCsNvK5hd92jY3S8oU/KbPOZJXMdhQHO5BOCLOp5FkzwFr5KvMfTaPL3gVKUfTcvKZi6t+FAahJZmi1x29mrJ4go/Mh0FgH4vSHsF+O8J35jq9R9mNxk7tdL4G8z3t8DiWsd9R/pq4QBTLSk/6i/YpVxhR31X9+jkKa/DriycbMtbW5MYd/LleK/lG0M+HGdTy+LhLUiq+XbceYRcLDTsbyDv0tQ+wE1+nVZpB0Irz0HiWoXTOcELOfXrA6N/mYD6tb2Ge5vm6wdWCwyjCLx8w3IggJIJ34lpLt11dTPpeKUgyhxSt9LIzVwd6nu2fHYzflULQ7t+VahOnCHgaYTLk5b2H7bkznHuwCjyJVqexvu9yGfiJxHzLzg8lTbHnwt9LfE3x9mwbL61ts8n64MlQiAeNpcoKbtwABTnaPKF04Wpp8YAwKQ== Bob Hooper
    # Open Contracting Partnership
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2AYzfKIjwrhN7Jg3RrQKK/YJSVo1OSXadbhgE8mKMLi5nuDN6v9g8+QodcCEdA/AjGIr25CtBWcLwvT33h0SfMZ9a8Csq2pv6IAQkigxMrr8aBE9TL8pqQuwcc7CS9PQNYFuqpKoC4PSvNGqn9NRPtZmPkmcIa+CL/G6Y48HY36jWsauI8T8l4gMeOkH9bfB1yNRmEwQAuA+PmGXgGSlx7Gj+TofOHNbWj1l7lThFyG73qQfqyMPmfHPIjyu1EfA4lBezjcgJXlE2VodrLTFfimORJLHk684xnmf7935KwmjBqIucD16PE/KSOyj+vQxXZCTLsQjDuXr3GexOJBXx James (OCP)
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDG8dhMVvgH/tt9+VoyokyUg/iKVcZKMku8pYN6o8RoT8XKoyP/iyrUIl5HxolqIt+PJTpomYkA40eJ/0mN4/kRhr+tctZ+tUdo8/G8H42FG3McklL6XlwOdXRGIYC+NynF8YGws57J8YkM2oL9linkUZYpGpVkNew2aEg916HWWfGZktwuQa7knIwIhFr9FlvxxaZhdcQ7VJjnJOP0fLLr5WCVaiWDGjQ5cHJURcTBL+j+eTRpKFvk9BMKCAQyLkSEluT0QeESDMtR7sRHA54to1LDXRX0ky9cAQ6mxXWgpSpmHCuPVYpzOfoSd7b8aczDLUGBxq9EWOTS3UMUWJBX Yohanna (OCP)

# The default locale is en_GB rather than en_US for accidental, historical reasons.
locale: en_GB

ntp:
  - 0.uk.pool.ntp.org
  - 1.uk.pool.ntp.org
  - 2.uk.pool.ntp.org
  - 3.uk.pool.ntp.org

smtp:
  relay: True
  relay_address: noreply@noreply.open-contracting.org

netdata:
  enabled: False

vm:
{% if grains.mem_total > 2048 %}
  swappiness: 10
{% else %}
  swappiness: 40
{% endif %}

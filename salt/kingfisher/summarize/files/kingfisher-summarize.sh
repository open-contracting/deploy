#!/bin/sh
(
    # shellcheck disable=SC1083
    cd {{ directory }} || exit
    # shellcheck source=/dev/null
    . .ve/bin/activate
    python manage.py "$@"
)

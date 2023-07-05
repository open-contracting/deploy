#!/bin/sh
(
    # shellcheck disable=SC1083
    cd {{ directory }} || exit
    . .ve/bin/activate
    python manage.py "$@"
)

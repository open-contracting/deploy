#!/bin/sh
(
    # shellcheck disable=SC1083
    cd {{ directory }} || exit
    .ve/bin/python manage.py "$@"
)

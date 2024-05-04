#!/bin/sh
(
    # shellcheck disable=SC1083
    cd {{ directory }} || exit
    # shellcheck disable=SC1083
    docker compose run --rm --name kingfisher-process-{{ command }} cron python manage.py {{ command }} "$@"
)

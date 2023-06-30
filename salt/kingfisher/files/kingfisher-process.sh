#!/bin/sh
(
    cd {{ directory }}
    docker compose run --rm web python manage.py {{ command }} "$@"
)

#!/usr/bin/env bash
# This script setups dockerized Redash on Ubuntu 18.04.

# https://raw.githubusercontent.com/getredash/setup/cb47626/setup.sh

set -euo pipefail

REDASH_BASE_PATH=/opt/redash

install_docker() {
    # Install Docker
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get -qqy update
    DEBIAN_FRONTEND=noninteractive sudo -E apt-get -qqy -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
    sudo apt-get -yy install ca-certificates software-properties-common wget pwgen
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update && sudo apt-get -y install docker-ce

    # Install Docker Compose
    sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # Allow current user to run Docker commands
    sudo usermod -aG docker "$USER"
}

create_directories() {
    if [ ! -e $REDASH_BASE_PATH ]; then
        sudo mkdir -p $REDASH_BASE_PATH
        sudo chown "$USER":"$USER" $REDASH_BASE_PATH
    fi

    if [ ! -e $REDASH_BASE_PATH/postgres-data ]; then
        mkdir $REDASH_BASE_PATH/postgres-data
    fi
}

create_config() {
    if [ -e $REDASH_BASE_PATH/env ]; then
        rm $REDASH_BASE_PATH/env
        touch $REDASH_BASE_PATH/env
    fi

    COOKIE_SECRET=$(pwgen -1s 32)
    SECRET_KEY=$(pwgen -1s 32)
    POSTGRES_PASSWORD=$(pwgen -1s 32)
    REDASH_DATABASE_URL="postgresql://postgres:$POSTGRES_PASSWORD@postgres/postgres"

    {
        echo "PYTHONUNBUFFERED=0"
        echo "REDASH_LOG_LEVEL=INFO"
        echo "REDASH_REDIS_URL=redis://redis:6379/0"
        echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD"
        echo "REDASH_COOKIE_SECRET=$COOKIE_SECRET"
        echo "REDASH_SECRET_KEY=$SECRET_KEY"
        echo "REDASH_DATABASE_URL=$REDASH_DATABASE_URL"
    } >> $REDASH_BASE_PATH/env
}

setup_compose() {
    REQUESTED_CHANNEL=stable
    LATEST_VERSION=$(curl -s "https://version.redash.io/api/releases?channel=$REQUESTED_CHANNEL" | json_pp | grep "docker_image" | head -n 1 | awk 'BEGIN{FS=":"}{print $3}' | awk 'BEGIN{FS="\""}{print $1}')

    cd $REDASH_BASE_PATH
    GIT_BRANCH="${REDASH_BRANCH:-master}" # Default branch/version to master if not specified in REDASH_BRANCH env var
    wget https://raw.githubusercontent.com/getredash/setup/"$GIT_BRANCH"/data/docker-compose.yml
    sed -ri "s/image: redash\/redash:([A-Za-z0-9.-]*)/image: redash\/redash:$LATEST_VERSION/" docker-compose.yml
    sed -i 's/80:80/9090:80/' /opt/redash/docker-compose.yml
    # shellcheck disable=SC1003
    sed -i '/postgresql/a\'$'\n''      - "5432:5432"' /opt/redash/docker-compose.yml
    # shellcheck disable=SC1003
    sed -i '/postgresql/a\'$'\n''    ports:' /opt/redash/docker-compose.yml
    echo "export COMPOSE_PROJECT_NAME=redash" >> ~/.profile
    echo "export COMPOSE_FILE=/opt/redash/docker-compose.yml" >> ~/.profile
    export COMPOSE_PROJECT_NAME=redash
    export COMPOSE_FILE=/opt/redash/docker-compose.yml
    # sudo docker-compose run --rm server create_db
    # sudo docker-compose up -d
}

# install_docker
create_directories
create_config
setup_compose

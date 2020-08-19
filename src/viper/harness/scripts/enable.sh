#!/usr/bin/env bash

main()
{
    passthru ws networks external

    if [ ! -f .my127ws/.flag-built ]; then
        passthru docker-compose down
        $APP_BUILD
        touch .my127ws/.flag-built
    else
        passthru docker-compose up -d
        passthru docker-compose exec -T -u node gateway app welcome
        passthru docker-compose exec -T -u node client app welcome
    fi

    if [[ "$APP_BUILD" = "dynamic" && "$USE_MUTAGEN" = "yes" ]]; then
        passthru ws mutagen resume
    fi
}

dynamic()
{
    # we synchronise then stop the sync as leaving it running during the build
    # will often cause it to crash.

    if [[ "$USE_MUTAGEN" = "yes" ]]; then
        passthru ws mutagen start
        passthru ws mutagen pause
    fi

    ws external-images pull
    
    passthru docker-compose build
    passthru docker-compose up -d

    passthru docker-compose exec -T -u node gateway app build
    passthru docker-compose exec -T -u node gateway app init

    passthru docker-compose exec -T -u node client app build
    passthru docker-compose exec -T -u node client app init
}

static()
{
    ws app build
    passthru docker-compose up -d
}

main

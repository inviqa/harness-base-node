#!/usr/bin/env bash

main()
{
    passthru ws networks external

    if [ ! -f .my127ws/.flag-built ]; then

        passthru $COMPOSE_BIN down

        if [[ "$APP_DYNAMIC" = "yes" ]]; then
            dynamic
        else
            static
        fi

        touch .my127ws/.flag-built

    else
        passthru $COMPOSE_BIN up -d
        passthru $COMPOSE_BIN exec -T -u node node app welcome
    fi

    if [[ "$APP_DYNAMIC" = "yes" && "$SYNC_STRATEGY" = "mutagen" ]]; then
        passthru ws mutagen resume
    fi
}

dynamic()
{
    # we synchronise then stop the sync as leaving it running during the build
    # will often cause it to crash.

    if [[ "$SYNC_STRATEGY" = "mutagen" ]]; then
        passthru ws mutagen start
        passthru ws mutagen pause
    fi

    ws external-images pull

    passthru $COMPOSE_BIN build
    passthru $COMPOSE_BIN up -d

    if [ ! -f package.json ]; then
        task skeleton:apply
    fi

    passthru $COMPOSE_BIN exec -T node app init
}

static()
{
    ws app build
    passthru $COMPOSE_BIN up -d
}

main

#!/usr/bin/env bash

if [[ "$SYNC_STRATEGY" = "mutagen" ]]; then
    run ws mutagen pause
fi

run $COMPOSE_BIN stop

#!/bin/bash

function task_build()
{
    if [ ! -f /app/package.json ]; then
        task skeleton:apply
    fi

    task overlay:apply

    task build:backend
    task build:gateway
    task build:client
}

#!/bin/bash

function task_init()
{
    if [ ! -f /app/package.json ]; then
        task "skeleton:apply"
    fi

    task "overlay:apply"
    task "welcome"
}

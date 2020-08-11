#!/bin/bash

function task_build()
{
    task "build:packages"
    task "build:gateway"
    task "build:client"
}

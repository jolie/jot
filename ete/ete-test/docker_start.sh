#!/bin/sh

docker compose up --abort-on-container-exit --attach $1 --exit-code-from $1 --force-recreate
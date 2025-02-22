#!/bin/sh
podman run --replace -d --name postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=soldata \
  -p 5432:5432 \
  -v pgdata:/var/lib/postgresql/data \
  docker.io/library/postgres 

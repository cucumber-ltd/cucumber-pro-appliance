#!/bin/bash
#
# Creates data directories for persistent data (docker volumes).
#
set -e pipefail

mkdir -p /var/lib/mongo/data
mkdir -p /var/lib/postgres/data
mkdir -p /var/lib/redis/data
# TODO - create a directory for metarepo attachment here too?

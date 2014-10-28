#!/bin/bash
#
# Creates data directories for persistent data (docker volumes).
#
set -e pipefail

mkdir -p /home/core/volumes/mongo/data
mkdir -p /home/core/volumes/postgres/data
mkdir -p /home/core/volumes/redis/data
# TODO - create a directory for metarepo attachment here too?

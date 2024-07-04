#!/bin/sh

set -e

rm -f /app/db.sqlite

litestream restore -if-replica-exists -config /etc/litestream.yml /app/db.sqlite

litestream replicate -exec /app/app -config /etc/litestream.yml

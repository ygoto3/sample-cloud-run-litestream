#!/bin/sh

cat init.sql | sqlite3 db.sqlite
litestream replicate -config ./litestream.yml

#!/bin/sh

cat init-dev.sql | sqlite3 db.sqlite
sea-orm-cli generate entity -u sqlite://db.sqlite -o src/entity

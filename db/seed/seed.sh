#!/bin/sh
PSQL="/usr/bin/psql"
DBNAME="soldata"
DBHOST="127.0.0.1"
DBPORT="5432"
DBUSER="postgres"
export PGPASSFILE='./.pass'

$PSQL -U $DBUSER -w -h $DBHOST -p $DBPORT $DBNAME < ./soldata_seed.sql
$PSQL -U $DBUSER -w -h $DBHOST -p $DBPORT $DBNAME < ./employee_seed.sql

#!/bin/sh
PSQL="/usr/bin/psql"
DBNAME="soldata"
DBHOST="127.0.0.1"
DBPORT="5432"
DBUSER="postgres"
export PGPASSFILE='./.pass'

$PSQL -U $DBUSER -w -h $DBHOST -p $DBPORT $DBNAME << EOF

DROP INDEX public.dates;
ALTER TABLE ONLY public.soldata DROP CONSTRAINT soldata_pkey;
ALTER TABLE ONLY public.schema_migrations DROP CONSTRAINT schema_migrations_pkey;
ALTER TABLE ONLY public.soldatarefrange DROP CONSTRAINT id;
ALTER TABLE ONLY public.calculationpattern DROP CONSTRAINT calculationpattern_pkey;
ALTER TABLE ONLY public.ar_internal_metadata DROP CONSTRAINT ar_internal_metadata_pkey;
DROP SEQUENCE public.soldatarefrange_id_seq;
DROP TABLE public.soldatarefrange;
DROP TABLE public.soldata;
DROP SEQUENCE public.soldata_seq;
DROP TABLE public.schema_migrations;
DROP SEQUENCE public.calculationpattern_id_seq;
DROP TABLE public.calculationpattern;
DROP TABLE public.ar_internal_metadata;
ALTER TABLE ONLY public.employee DROP CONSTRAINT uniq;
DROP TABLE public.employee;

SET default_tablespace = '';

EOF

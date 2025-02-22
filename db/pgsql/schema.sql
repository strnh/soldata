--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 16.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO postgres;

--
-- Name: calculationpattern; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calculationpattern (
    id integer DEFAULT nextval(('public.calculationpattern_id_seq'::text)::regclass) NOT NULL,
    name character varying(32),
    strpattern character varying(254)
);


ALTER TABLE public.calculationpattern OWNER TO postgres;

--
-- Name: calculationpattern_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.calculationpattern_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.calculationpattern_id_seq OWNER TO postgres;

--
-- Name: calculationpattern_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.calculationpattern_id_seq OWNED BY public.calculationpattern.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: soldata_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.soldata_seq
    START WITH 2285
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.soldata_seq OWNER TO postgres;

--
-- Name: soldata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soldata (
    id integer DEFAULT nextval('public.soldata_seq'::regclass) NOT NULL,
    date timestamp without time zone,
    sid integer,
    kid integer,
    fnaoh1 double precision,
    fnaoh2 double precision,
    fedta double precision,
    fi double precision,
    fhcl double precision,
    fagno3 double precision,
    fna2s2o3 double precision,
    etcrox double precision,
    etcroxv double precision,
    etcr3x double precision,
    etcr3v double precision,
    etso4x double precision,
    etso4v double precision,
    predip1 double precision,
    predip2 double precision,
    crpmpdx double precision,
    crpmpdv double precision,
    crphclx double precision,
    crphclv double precision,
    crpsnclx double precision,
    crpsnclv double precision,
    crptotsnx double precision,
    crptotsnv double precision,
    selcux double precision,
    selcuv double precision,
    selakx double precision,
    selakv double precision,
    selbx double precision,
    selbv double precision,
    cuscusx double precision,
    cuscusv double precision,
    cusso4x double precision,
    cusso4v double precision,
    cusclox double precision,
    cusclov double precision,
    snitotnix double precision,
    snitotniv double precision,
    sninisox double precision,
    sninisov double precision,
    sniniclx double precision,
    sniniclv double precision,
    snibx double precision,
    snibv double precision,
    crcro3x double precision,
    crcro3v double precision,
    crtcx double precision,
    crtcv double precision,
    crso4x double precision,
    crso4v double precision,
    memo character varying(255),
    etparadv double precision DEFAULT 0.0,
    etparadx double precision DEFAULT 0.0,
    craccr double precision DEFAULT 0,
    craccrv double precision DEFAULT 0,
    cracso double precision DEFAULT 0.0,
    cracsov double precision DEFAULT 0,
    crpclpdv double precision,
    crpc85v double precision
);


ALTER TABLE public.soldata OWNER TO postgres;

--
-- Name: soldatarefrange; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.soldatarefrange (
    id bigint DEFAULT nextval(('public.soldatarefrange_id_seq'::text)::regclass) NOT NULL,
    komoku character varying(64),
    kclass character varying(24),
    goalparam double precision,
    range character varying(32),
    kid integer,
    day_start timestamp with time zone,
    day_end timestamp with time zone
);


ALTER TABLE public.soldatarefrange OWNER TO postgres;

--
-- Name: soldatarefrange_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.soldatarefrange_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.soldatarefrange_id_seq OWNER TO postgres;

--
-- Name: soldatarefrange_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.soldatarefrange_id_seq OWNED BY public.soldatarefrange.id;


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: calculationpattern calculationpattern_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calculationpattern
    ADD CONSTRAINT calculationpattern_pkey PRIMARY KEY (id);


--
-- Name: soldatarefrange id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldatarefrange
    ADD CONSTRAINT id PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: soldata soldata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.soldata
    ADD CONSTRAINT soldata_pkey PRIMARY KEY (id);


--
-- Name: dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX dates ON public.soldata USING btree (date);


--
-- Name: TABLE soldata; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.soldata TO postgres;


--
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    uid integer NOT NULL,
    name character varying(128),
    bid integer
);


ALTER TABLE public.employee OWNER TO postgres;


--
-- PostgreSQL database dump complete
--

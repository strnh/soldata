--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6
-- Dumped by pg_dump version 16.6 (Ubuntu 16.6-0ubuntu0.24.04.1)

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

--
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.employee (uid, name, bid) VALUES (0, '', 0);
INSERT INTO public.employee (uid, name, bid) VALUES (2, 'user1', 2);
INSERT INTO public.employee (uid, name, bid) VALUES (4, 'user2', 4);
INSERT INTO public.employee (uid, name, bid) VALUES (999, '開発', 999);
INSERT INTO public.employee (uid, name, bid) VALUES (500, 'strnh', 500);
INSERT INTO public.employee (uid, name, bid) VALUES (10001, 'ほげ', 10001);
INSERT INTO public.employee (uid, name, bid) VALUES (10002, '作業者', 10002);
INSERT INTO public.employee (uid, name, bid) VALUES (10003, 'user5', 10003);


--
-- PostgreSQL database dump complete
--


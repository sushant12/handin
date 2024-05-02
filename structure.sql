--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: assignment_submission_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment_submission_files (
    id uuid NOT NULL,
    file character varying(255),
    assignment_submission_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.assignment_submission_files OWNER TO postgres;

--
-- Name: assignment_submission_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment_submission_tests (
    id uuid NOT NULL,
    failed_at timestamp(0) without time zone,
    assignment_submission_id uuid,
    assignment_test_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.assignment_submission_tests OWNER TO postgres;

--
-- Name: assignment_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment_submissions (
    id uuid NOT NULL,
    user_id uuid,
    assignment_id uuid,
    submitted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    retries integer DEFAULT 0,
    total_points double precision
);


ALTER TABLE public.assignment_submissions OWNER TO postgres;

--
-- Name: assignment_submissions_builds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment_submissions_builds (
    id uuid NOT NULL,
    assignment_submission_id uuid,
    build_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE public.assignment_submissions_builds OWNER TO postgres;

--
-- Name: assignment_tests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignment_tests (
    id uuid NOT NULL,
    name character varying(255),
    assignment_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    points_on_pass double precision,
    points_on_fail double precision,
    command character varying(255),
    expected_output_type character varying(255),
    expected_output_text character varying(255),
    expected_output_file character varying(255),
    ttl integer,
    expected_output_file_content text,
    enable_custom_test boolean,
    custom_test character varying(255)
);


ALTER TABLE public.assignment_tests OWNER TO postgres;

--
-- Name: assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.assignments (
    id uuid NOT NULL,
    name character varying(255),
    total_marks integer,
    start_date timestamp(0) without time zone,
    due_date timestamp(0) without time zone,
    cutoff_date timestamp(0) without time zone,
    max_attempts integer,
    penalty_per_day double precision,
    module_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    programming_language_id uuid,
    run_script character varying(255),
    attempt_marks integer,
    enable_cutoff_date boolean,
    enable_attempt_marks boolean,
    enable_penalty_per_day boolean,
    enable_max_attempts boolean,
    enable_total_marks boolean,
    enable_test_output boolean
);


ALTER TABLE public.assignments OWNER TO postgres;

--
-- Name: builds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.builds (
    id uuid NOT NULL,
    machine_id character varying(255),
    status character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    assignment_id uuid,
    user_id uuid
);


ALTER TABLE public.builds OWNER TO postgres;

--
-- Name: custom_assignment_dates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_assignment_dates (
    id uuid NOT NULL,
    assignment_id uuid,
    user_id uuid,
    start_date timestamp(0) without time zone,
    due_date timestamp(0) without time zone,
    enable_cutoff_date boolean,
    cutoff_date timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.custom_assignment_dates OWNER TO postgres;

--
-- Name: lecturer_assignment_submissions_builds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lecturer_assignment_submissions_builds (
    id uuid NOT NULL,
    assignment_submission_id uuid,
    build_id uuid,
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.lecturer_assignment_submissions_builds OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id uuid NOT NULL,
    output text,
    build_id uuid,
    inserted_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    assignment_test_id uuid,
    command character varying(255),
    expected_output text
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: module; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.module (
    id uuid NOT NULL,
    name character varying(255),
    code character varying(255),
    deleted_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.module OWNER TO postgres;

--
-- Name: modules_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules_invitations (
    id uuid NOT NULL,
    email character varying(255),
    module_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.modules_invitations OWNER TO postgres;

--
-- Name: modules_users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules_users (
    id uuid NOT NULL,
    module_id uuid,
    user_id uuid,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.modules_users OWNER TO postgres;

--
-- Name: programming_languages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.programming_languages (
    id uuid NOT NULL,
    name character varying(255),
    docker_file_url character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.programming_languages OWNER TO postgres;

--
-- Name: run_script_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.run_script_results (
    id uuid NOT NULL,
    build_id uuid,
    assignment_id uuid,
    user_id uuid,
    state character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.run_script_results OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: solution_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.solution_files (
    id uuid NOT NULL,
    file character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    assignment_id uuid
);


ALTER TABLE public.solution_files OWNER TO postgres;

--
-- Name: support_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_files (
    id uuid NOT NULL,
    file character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    assignment_id uuid
);


ALTER TABLE public.support_files OWNER TO postgres;

--
-- Name: test_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.test_results (
    id uuid NOT NULL,
    build_id uuid,
    assignment_test_id uuid,
    user_id uuid,
    state character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.test_results OWNER TO postgres;

--
-- Name: universities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.universities (
    id uuid NOT NULL,
    name character varying(255),
    student_email_regex character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    timezone character varying(255)
);


ALTER TABLE public.universities OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    role character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    university_id uuid
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.users_tokens OWNER TO postgres;

--
-- Data for Name: assignment_submission_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignment_submission_files (id, file, assignment_submission_id, inserted_at, updated_at) FROM stdin;
8fbd1fc8-4df3-4972-b632-79fb75fded00	handin.html?63881860548	2c95b762-3dbe-4942-a28b-2143de9df692	2024-05-02 09:15:48	2024-05-02 09:15:48
5719a742-2c30-45b1-beec-385347db7e4f	handin.html?63881860946	c3035087-ab10-4341-85d3-2e941c23f956	2024-05-02 09:22:25	2024-05-02 09:22:26
ca974aaf-d28c-4a7f-accb-3529cfd03196	handin.html?63881861117	986e062f-a250-4b9d-9494-e497f83dd0c3	2024-05-02 09:25:17	2024-05-02 09:25:17
\.


--
-- Data for Name: assignment_submission_tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignment_submission_tests (id, failed_at, assignment_submission_id, assignment_test_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: assignment_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignment_submissions (id, user_id, assignment_id, submitted_at, inserted_at, updated_at, retries, total_points) FROM stdin;
2c95b762-3dbe-4942-a28b-2143de9df692	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 11:42:26	2024-05-02 09:15:38	2024-05-02 11:42:26	0	2
c3035087-ab10-4341-85d3-2e941c23f956	e7599eb1-f783-4b01-ae67-1e6cb683c61b	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 11:43:15	2024-05-02 09:22:21	2024-05-02 11:43:15	0	2
986e062f-a250-4b9d-9494-e497f83dd0c3	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 11:44:43	2024-05-02 09:25:12	2024-05-02 09:25:12	0	0
\.


--
-- Data for Name: assignment_submissions_builds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignment_submissions_builds (id, assignment_submission_id, build_id, inserted_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: assignment_tests; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignment_tests (id, name, assignment_id, inserted_at, updated_at, points_on_pass, points_on_fail, command, expected_output_type, expected_output_text, expected_output_file, ttl, expected_output_file_content, enable_custom_test, custom_test) FROM stdin;
7cb4f6d1-7a23-47c1-8d58-a7000eecc811	Test 1	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 07:47:01	2024-05-02 11:39:56	1	0	./main 1 2	string	3	\N	60	\N	f	\N
3e2e9ef1-7cba-403d-944f-52684449a161	Test 2	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 07:47:01	2024-05-02 11:46:26	1	0	./main 2 2	string	3	\N	60	\N	f	\N
12d00c01-4e99-4706-aa29-56db101d5f55	Test 3	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 07:47:01	2024-05-02 11:46:30	1	0	./main 3 2	string	3	\N	60	\N	f	\N
c8c029e5-7dca-4cd0-b4af-a960178371ba	Test 4	42b6b174-6b57-4f74-a222-9257c2297fba	2024-05-02 07:47:01	2024-05-02 11:46:35	1	0	./main 4 2	string	3	\N	60	\N	f	\N
\.


--
-- Data for Name: assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.assignments (id, name, total_marks, start_date, due_date, cutoff_date, max_attempts, penalty_per_day, module_id, inserted_at, updated_at, programming_language_id, run_script, attempt_marks, enable_cutoff_date, enable_attempt_marks, enable_penalty_per_day, enable_max_attempts, enable_total_marks, enable_test_output) FROM stdin;
42b6b174-6b57-4f74-a222-9257c2297fba	Week 0	5	2024-05-02 07:47:00	2024-05-04 07:47:00	\N	\N	\N	be8f2379-c966-4b9f-807d-87d72fb12390	2024-05-02 07:47:01	2024-05-02 11:39:51	aec4d82c-aff5-4d17-a036-c342a0159d7c	g++ main.cpp -o main	1	f	t	f	f	t	f
\.


--
-- Data for Name: builds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.builds (id, machine_id, status, inserted_at, updated_at, assignment_id, user_id) FROM stdin;
eff4efe0-9122-4a53-8f08-b631f1ee2518	e82d924a071268	running	2024-05-02 09:15:49	2024-05-02 09:15:49	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
a232b07b-6766-4553-800c-070a2754326c	e82d924a071268	running	2024-05-02 09:16:28	2024-05-02 09:16:28	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
59fa01f6-c47f-4ddf-a0dc-824657812461	e82d924a071268	completed	2024-05-02 09:20:55	2024-05-02 09:21:07	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
7aa53295-a2ee-40cd-b71e-39dbac68c3a2	e82d924a071268	completed	2024-05-02 09:21:15	2024-05-02 09:21:27	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	e82d924a071268	completed	2024-05-02 09:23:31	2024-05-02 09:23:43	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b
ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	e82d924a071268	completed	2024-05-02 09:24:27	2024-05-02 09:24:39	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b
8283ee41-2447-4724-b6a1-bd3f8feac84a	e82d924a071268	failed	2024-05-02 09:26:49	2024-05-02 09:26:49	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
a6bc1aa1-34d9-4043-8c9f-2eb495649ad2	e82d924a071268	failed	2024-05-02 09:26:53	2024-05-02 09:26:53	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
cc701f39-ae47-4353-8bc5-892f8f6914e5	e82d924a071268	failed	2024-05-02 09:26:58	2024-05-02 09:26:58	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
1783d597-5228-4ebd-9acd-1c0160e089a1	e82d924a071268	failed	2024-05-02 09:27:17	2024-05-02 09:27:17	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
5031dff6-323c-4524-83ca-a6a5da38129d	e82d924a071268	failed	2024-05-02 09:28:16	2024-05-02 09:28:16	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
729a07c7-9005-4de7-87d1-9bdaeb20a660	\N	running	2024-05-02 11:41:31	2024-05-02 11:41:31	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
b102c7a6-2991-4c49-95c9-200e06d2c9bb	e82d924a071268	completed	2024-05-02 11:42:14	2024-05-02 11:42:26	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a
e6a99d0c-7077-49b8-883d-2fafbf391805	e82d924a071268	completed	2024-05-02 11:43:03	2024-05-02 11:43:15	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b
24920448-346d-4285-9d54-f4100a380338	e82d924a071268	failed	2024-05-02 11:44:43	2024-05-02 11:44:43	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96
\.


--
-- Data for Name: custom_assignment_dates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_assignment_dates (id, assignment_id, user_id, start_date, due_date, enable_cutoff_date, cutoff_date, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: lecturer_assignment_submissions_builds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lecturer_assignment_submissions_builds (id, assignment_submission_id, build_id, deleted_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, output, build_id, inserted_at, updated_at, assignment_test_id, command, expected_output) FROM stdin;
43b5a6b0-266a-442e-ab4e-87bd5978ef65	{"state":"pass"}	59fa01f6-c47f-4ddf-a0dc-824657812461	2024-05-02 09:20:55.430459	2024-05-02 09:20:55.430459	\N	sh ./main.sh	\N
b64333cf-7b3b-4c20-9521-6d39a20ae5e9	\N	59fa01f6-c47f-4ddf-a0dc-824657812461	2024-05-02 09:20:58.453046	2024-05-02 09:20:58.453046	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
f28a78c7-9ea7-4c27-b129-aca84424e43f	\N	59fa01f6-c47f-4ddf-a0dc-824657812461	2024-05-02 09:21:01.476712	2024-05-02 09:21:01.476712	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
b6e11921-c67f-4ff3-a285-e59117a154f6	\N	59fa01f6-c47f-4ddf-a0dc-824657812461	2024-05-02 09:21:04.496224	2024-05-02 09:21:04.496224	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
6463a4cb-63dd-4262-8afe-29fba7d81d55	\N	59fa01f6-c47f-4ddf-a0dc-824657812461	2024-05-02 09:21:07.516722	2024-05-02 09:21:07.516722	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
53196433-c83c-43d4-abdf-6bdd033ac23f	{"state":"pass"}	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	2024-05-02 09:21:15.461936	2024-05-02 09:21:15.461936	\N	sh ./main.sh	\N
bb3edbd7-99b3-4de6-9dc9-b9b95cae7f4d	\N	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	2024-05-02 09:21:18.481108	2024-05-02 09:21:18.481108	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
5df340d2-4fb3-4352-81c4-9d7f0bc4686a	\N	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	2024-05-02 09:21:21.489946	2024-05-02 09:21:21.489946	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
05a29779-dd96-4e25-93f2-30a28749f9f8	\N	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	2024-05-02 09:21:24.496254	2024-05-02 09:21:24.496254	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
eb5f8ea1-3877-4ec7-a2ce-44fdbc0ac5bf	\N	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	2024-05-02 09:21:27.512674	2024-05-02 09:21:27.512674	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
88579fbb-af19-498a-a1d3-3c8ee4cd5659	{"state":"fail"}	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	2024-05-02 09:23:31.707119	2024-05-02 09:23:31.707119	\N	sh ./main.sh	\N
02e82183-6dac-4d36-a728-1c830d9b6b68	\N	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	2024-05-02 09:23:34.73073	2024-05-02 09:23:34.73073	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
9c65f391-b362-48b1-b2f3-c7c28985c2cf	\N	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	2024-05-02 09:23:37.757987	2024-05-02 09:23:37.757987	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
629c5d81-17af-45cc-b32e-5bdaa8c3e2da	\N	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	2024-05-02 09:23:40.77958	2024-05-02 09:23:40.77958	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
e2c3a6f5-8970-4a7e-9663-73264c2be324	\N	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	2024-05-02 09:23:43.798402	2024-05-02 09:23:43.798402	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
566dd618-8873-45be-982e-5145b95dc7a4	{"state":"pass"}	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	2024-05-02 09:24:27.71518	2024-05-02 09:24:27.71518	\N	sh ./main.sh	\N
adddb728-72bf-4cb9-a286-81eb3ff95d37	\N	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	2024-05-02 09:24:30.736371	2024-05-02 09:24:30.736371	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
67f3d9d5-f789-4211-87d6-6dd90e215ee9	\N	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	2024-05-02 09:24:33.76226	2024-05-02 09:24:33.76226	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
4f21c650-b2b8-4068-94e3-a67d606f79ec	\N	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	2024-05-02 09:24:36.791767	2024-05-02 09:24:36.791767	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
8981fe1d-e4d9-4e8e-a0f9-ca14276db0e0	\N	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	2024-05-02 09:24:39.819057	2024-05-02 09:24:39.819057	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
ba72cbcd-9415-4548-818d-4554faa54097	\N	8283ee41-2447-4724-b6a1-bd3f8feac84a	2024-05-02 09:26:49.839282	2024-05-02 09:26:49.839282	\N	sh ./main.sh	\N
f381c962-bff3-4b00-82b0-800eb1eb1bbd	\N	a6bc1aa1-34d9-4043-8c9f-2eb495649ad2	2024-05-02 09:26:53.847949	2024-05-02 09:26:53.847949	\N	sh ./main.sh	\N
866c701e-dfe7-4011-9f96-fa4dff1ca07c	\N	cc701f39-ae47-4353-8bc5-892f8f6914e5	2024-05-02 09:26:58.837592	2024-05-02 09:26:58.837592	\N	sh ./main.sh	\N
45414111-0b5e-44fe-a106-62d3cee41613	\N	1783d597-5228-4ebd-9acd-1c0160e089a1	2024-05-02 09:27:17.347079	2024-05-02 09:27:17.347079	\N	sh ./main.sh	\N
8b1535be-78c5-4e74-9fc8-77dfc0919e62	\N	5031dff6-323c-4524-83ca-a6a5da38129d	2024-05-02 09:28:16.566181	2024-05-02 09:28:16.566181	\N	sh ./main.sh	\N
77f1654c-5c1c-403a-aeec-74397b2480bb	{"state":"pass"}	b102c7a6-2991-4c49-95c9-200e06d2c9bb	2024-05-02 11:42:14.40807	2024-05-02 11:42:14.40807	\N	sh ./main.sh	\N
2f0839cd-2fd3-462f-b376-1fd3bf7e208b	\N	b102c7a6-2991-4c49-95c9-200e06d2c9bb	2024-05-02 11:42:17.432042	2024-05-02 11:42:17.432042	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
0069e6c8-138c-4310-bb79-d10961bc8046	\N	b102c7a6-2991-4c49-95c9-200e06d2c9bb	2024-05-02 11:42:20.459907	2024-05-02 11:42:20.459907	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
e9be8cdf-f696-4a6c-a42e-af9ad38814be	\N	b102c7a6-2991-4c49-95c9-200e06d2c9bb	2024-05-02 11:42:23.475554	2024-05-02 11:42:23.475554	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
3dc7a0bc-a360-477a-9c08-8a11ec00b1c8	\N	b102c7a6-2991-4c49-95c9-200e06d2c9bb	2024-05-02 11:42:26.496746	2024-05-02 11:42:26.496746	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
68a61418-7497-4cde-a12a-57faeb33f5c5	{"state":"fail"}	e6a99d0c-7077-49b8-883d-2fafbf391805	2024-05-02 11:43:03.085102	2024-05-02 11:43:03.085102	\N	sh ./main.sh	\N
eeddced0-9b27-4183-b5a2-2e323b4820e3	\N	e6a99d0c-7077-49b8-883d-2fafbf391805	2024-05-02 11:43:06.105574	2024-05-02 11:43:06.105574	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	./main 1 2	\N
c39edc8f-6731-4f6e-9eb7-bae17f1b85a7	\N	e6a99d0c-7077-49b8-883d-2fafbf391805	2024-05-02 11:43:09.12567	2024-05-02 11:43:09.12567	3e2e9ef1-7cba-403d-944f-52684449a161	./main 1 2	\N
ac9e31d8-0bb7-4c26-9f78-d408f0a47d85	\N	e6a99d0c-7077-49b8-883d-2fafbf391805	2024-05-02 11:43:12.144738	2024-05-02 11:43:12.144738	12d00c01-4e99-4706-aa29-56db101d5f55	./main 1 2	\N
ffc4e5ff-8fb6-49ae-8e5a-2b01c4d1a48c	\N	e6a99d0c-7077-49b8-883d-2fafbf391805	2024-05-02 11:43:15.163002	2024-05-02 11:43:15.163002	c8c029e5-7dca-4cd0-b4af-a960178371ba	./main 1 2	\N
d70eb340-7e4e-4499-a905-054be37fca19	\N	24920448-346d-4285-9d54-f4100a380338	2024-05-02 11:44:43.861656	2024-05-02 11:44:43.861656	\N	sh ./main.sh	\N
\.


--
-- Data for Name: module; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.module (id, name, code, deleted_at, inserted_at, updated_at) FROM stdin;
be8f2379-c966-4b9f-807d-87d72fb12390	Data Structure and Algorithms	CS100	\N	2024-05-02 07:47:01	2024-05-02 07:47:01
\.


--
-- Data for Name: modules_invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modules_invitations (id, email, module_id, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: modules_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modules_users (id, module_id, user_id, inserted_at, updated_at) FROM stdin;
3fee0cc6-dcec-4353-90f5-a9101aa06932	be8f2379-c966-4b9f-807d-87d72fb12390	d1248f86-29ad-40e5-ad45-6cffcbb34cb8	2024-05-02 07:47:01	2024-05-02 07:47:01
b16814ae-ff55-45a1-9e1a-2816efa195f5	be8f2379-c966-4b9f-807d-87d72fb12390	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	2024-05-02 07:47:01	2024-05-02 07:47:01
19ba70ff-f81d-42e2-8c66-601f6cfe972a	be8f2379-c966-4b9f-807d-87d72fb12390	e7599eb1-f783-4b01-ae67-1e6cb683c61b	2024-05-02 07:47:01	2024-05-02 07:47:01
637295a2-962e-4d1f-8042-251413e548ff	be8f2379-c966-4b9f-807d-87d72fb12390	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96	2024-05-02 07:47:01	2024-05-02 07:47:01
1f641bf1-7acd-44b0-add2-d83d306908e7	be8f2379-c966-4b9f-807d-87d72fb12390	521ae012-c22b-4944-955d-35ebb81f8a9c	2024-05-02 07:47:02	2024-05-02 07:47:02
2b2cd994-43ad-428f-849a-d906bfe6cafa	be8f2379-c966-4b9f-807d-87d72fb12390	1d8606da-3906-4dd8-9864-d7ca100c5161	2024-05-02 07:47:02	2024-05-02 07:47:02
a097be3c-a450-40ec-92ce-a491210e5752	be8f2379-c966-4b9f-807d-87d72fb12390	2f0b1354-47a1-4a4c-ac8e-552ebe9e535c	2024-05-02 07:47:02	2024-05-02 07:47:02
673ac44f-3512-4415-87f3-551bc9d5a6b4	be8f2379-c966-4b9f-807d-87d72fb12390	b629ab30-2a31-4806-af38-bdde388d698f	2024-05-02 07:47:02	2024-05-02 07:47:02
1eb0178f-0364-4b34-b8d0-104a7f49ec95	be8f2379-c966-4b9f-807d-87d72fb12390	fe530f36-3677-46cc-bdf7-390dc099f211	2024-05-02 07:47:02	2024-05-02 07:47:02
0ce10558-ac08-4c19-bf11-9c8c8987e9a8	be8f2379-c966-4b9f-807d-87d72fb12390	14efdd07-8079-4218-90a9-28ab17600d3f	2024-05-02 07:47:03	2024-05-02 07:47:03
e0ee570b-4900-4106-a431-169dc35c5dac	be8f2379-c966-4b9f-807d-87d72fb12390	a5b5514b-13c4-4017-a6e6-0d72afeb4b4c	2024-05-02 07:47:03	2024-05-02 07:47:03
f4f07a0d-7c00-4f03-a777-f6fa1cd6967f	be8f2379-c966-4b9f-807d-87d72fb12390	be348edc-3c57-4b03-92a0-8f7607192438	2024-05-02 07:47:03	2024-05-02 07:47:03
deefa195-8a98-488e-9f26-97c22ffdf618	be8f2379-c966-4b9f-807d-87d72fb12390	1f4b5535-4ad1-48b8-9b88-ce793b9beafd	2024-05-02 07:47:03	2024-05-02 07:47:03
89e08f37-078c-4b17-9932-1f21a2660bb7	be8f2379-c966-4b9f-807d-87d72fb12390	05cca4ab-c116-4191-b524-af6773006ee8	2024-05-02 07:47:03	2024-05-02 07:47:03
afc48fd2-2bee-4557-b858-da248df46b5b	be8f2379-c966-4b9f-807d-87d72fb12390	549a7f6f-9419-4388-ad04-cd211976c88b	2024-05-02 07:47:03	2024-05-02 07:47:03
62578ee0-830a-4701-9d6c-24278b88e9f8	be8f2379-c966-4b9f-807d-87d72fb12390	61d86648-714e-4769-963f-989de17be1e6	2024-05-02 07:47:04	2024-05-02 07:47:04
ec6ea7d9-dea1-4513-8507-f3632a725de9	be8f2379-c966-4b9f-807d-87d72fb12390	f262d130-10bd-4036-bf74-da4477037502	2024-05-02 07:47:04	2024-05-02 07:47:04
29176335-6b85-41c9-8ef6-0c5b582a098b	be8f2379-c966-4b9f-807d-87d72fb12390	9daa4dbe-bad4-44f6-8822-6f00eba45755	2024-05-02 07:47:04	2024-05-02 07:47:04
3af307c7-2ec6-4e5a-9e0d-8f9cb773ecd5	be8f2379-c966-4b9f-807d-87d72fb12390	3b3cf879-527e-4e14-80a9-4c87a1ca023d	2024-05-02 07:47:04	2024-05-02 07:47:04
cc7ba377-5f2c-4ee1-b375-0222509d4e90	be8f2379-c966-4b9f-807d-87d72fb12390	9cfba96f-cb93-41af-aba5-cf0a5a0b69ad	2024-05-02 07:47:04	2024-05-02 07:47:04
e1215174-61df-4e49-9f62-044c51263cb3	be8f2379-c966-4b9f-807d-87d72fb12390	a75d9b97-166b-41a9-b82a-573a945b275f	2024-05-02 07:47:05	2024-05-02 07:47:05
\.


--
-- Data for Name: programming_languages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.programming_languages (id, name, docker_file_url, inserted_at, updated_at) FROM stdin;
aec4d82c-aff5-4d17-a036-c342a0159d7c	cpp	sushantbajracharya/cpp:latest	2024-05-02 07:47:01	2024-05-02 07:47:01
\.


--
-- Data for Name: run_script_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.run_script_results (id, build_id, assignment_id, user_id, state, inserted_at, updated_at) FROM stdin;
5077aa75-50ea-4928-899e-3e14698e33e3	eff4efe0-9122-4a53-8f08-b631f1ee2518	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:15:49	2024-05-02 09:15:49
26012ed9-ffa1-4366-ab64-15c889ff7b1d	a232b07b-6766-4553-800c-070a2754326c	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:16:28	2024-05-02 09:16:28
a9f642cf-73cb-46ad-b939-757b095d58f9	59fa01f6-c47f-4ddf-a0dc-824657812461	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:20:55	2024-05-02 09:20:55
f3d5d4a9-5fe6-49a5-80cb-085463cb2fa6	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:15	2024-05-02 09:21:15
0b78463f-234a-4741-9feb-f805149cc366	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 09:23:31	2024-05-02 09:23:31
b8b7aebf-b267-4e21-8299-5eeecb874e8d	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 09:24:27	2024-05-02 09:24:27
6f9aa4e8-408f-4c8a-bb45-41820320e804	5031dff6-323c-4524-83ca-a6a5da38129d	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96	fail	2024-05-02 09:28:16	2024-05-02 09:28:16
315049bf-2394-4839-b035-3f0cd6dd04bf	b102c7a6-2991-4c49-95c9-200e06d2c9bb	42b6b174-6b57-4f74-a222-9257c2297fba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 11:42:14	2024-05-02 11:42:14
e2c90b23-605f-4ba2-9ab7-c44637cd32b9	e6a99d0c-7077-49b8-883d-2fafbf391805	42b6b174-6b57-4f74-a222-9257c2297fba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 11:43:03	2024-05-02 11:43:03
a774ce56-b8c4-400d-aefe-935737f84718	24920448-346d-4285-9d54-f4100a380338	42b6b174-6b57-4f74-a222-9257c2297fba	62b4ccd4-fe16-436c-88ad-54e9fcbb0b96	fail	2024-05-02 11:44:43	2024-05-02 11:44:43
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20230611133131	2024-05-02 07:46:59
20230615114418	2024-05-02 07:46:59
20230615114641	2024-05-02 07:46:59
20230722150824	2024-05-02 07:47:00
20230723124113	2024-05-02 07:47:00
20230731200813	2024-05-02 07:47:00
20230806113845	2024-05-02 07:47:00
20230807023215	2024-05-02 07:47:00
20230807110021	2024-05-02 07:47:00
20230820111727	2024-05-02 07:47:00
20230820123928	2024-05-02 07:47:00
20230820123929	2024-05-02 07:47:00
20230826192737	2024-05-02 07:47:00
20230826192801	2024-05-02 07:47:00
20230826192820	2024-05-02 07:47:00
20230826194403	2024-05-02 07:47:00
20230907150703	2024-05-02 07:47:00
20230909082303	2024-05-02 07:47:00
20230909221021	2024-05-02 07:47:00
20230909225807	2024-05-02 07:47:00
20230911122128	2024-05-02 07:47:00
20231120024301	2024-05-02 07:47:00
20231120060459	2024-05-02 07:47:00
20231120060951	2024-05-02 07:47:00
20231125144107	2024-05-02 07:47:00
20231125151656	2024-05-02 07:47:00
20231126092859	2024-05-02 07:47:00
20231126125406	2024-05-02 07:47:00
20231126144526	2024-05-02 07:47:00
20231126160320	2024-05-02 07:47:00
20231203222042	2024-05-02 07:47:00
20231210121518	2024-05-02 07:47:00
20231210125237	2024-05-02 07:47:00
20231210233606	2024-05-02 07:47:00
20231217110905	2024-05-02 07:47:00
20231219123351	2024-05-02 07:47:00
20231220124702	2024-05-02 07:47:00
20231223072421	2024-05-02 07:47:00
20231226194015	2024-05-02 07:47:00
20231228173752	2024-05-02 07:47:00
20240111144236	2024-05-02 07:47:00
20240115114543	2024-05-02 07:47:00
20240116215736	2024-05-02 07:47:00
20240318130709	2024-05-02 07:47:00
\.


--
-- Data for Name: solution_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.solution_files (id, file, inserted_at, updated_at, assignment_id) FROM stdin;
\.


--
-- Data for Name: support_files; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.support_files (id, file, inserted_at, updated_at, assignment_id) FROM stdin;
\.


--
-- Data for Name: test_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.test_results (id, build_id, assignment_test_id, user_id, state, inserted_at, updated_at) FROM stdin;
74e26742-9987-4c9d-8b2f-73a3a516499b	59fa01f6-c47f-4ddf-a0dc-824657812461	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:20:58	2024-05-02 09:20:58
8d4000f8-cb75-4e91-8e48-c446a886ef0c	59fa01f6-c47f-4ddf-a0dc-824657812461	3e2e9ef1-7cba-403d-944f-52684449a161	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:01	2024-05-02 09:21:01
2c1c9c40-56de-42e0-a2ed-f6e252277cd4	59fa01f6-c47f-4ddf-a0dc-824657812461	12d00c01-4e99-4706-aa29-56db101d5f55	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:04	2024-05-02 09:21:04
f3c831ab-bc1f-44c1-b85c-c9e789675279	59fa01f6-c47f-4ddf-a0dc-824657812461	c8c029e5-7dca-4cd0-b4af-a960178371ba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:07	2024-05-02 09:21:07
8deb1ae4-d7e5-41d8-8f2e-841740770064	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:18	2024-05-02 09:21:18
81fbe640-3f69-48fe-8c22-b7f57a24c67a	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	3e2e9ef1-7cba-403d-944f-52684449a161	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:21	2024-05-02 09:21:21
aa360d47-732a-4582-8e89-1d632c6b4218	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	12d00c01-4e99-4706-aa29-56db101d5f55	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:24	2024-05-02 09:21:24
a871a085-778d-416e-89f2-45dca69ff13e	7aa53295-a2ee-40cd-b71e-39dbac68c3a2	c8c029e5-7dca-4cd0-b4af-a960178371ba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 09:21:27	2024-05-02 09:21:27
5f5fb458-fa55-483d-a843-2048fe9f27ee	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 09:23:34	2024-05-02 09:23:34
d8a8e464-5c2b-4e19-aa2d-24eb1d267591	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	3e2e9ef1-7cba-403d-944f-52684449a161	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 09:23:37	2024-05-02 09:23:37
b2bc7071-a4a2-410c-ad05-c08d2faf88b3	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	12d00c01-4e99-4706-aa29-56db101d5f55	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 09:23:40	2024-05-02 09:23:40
67a71c87-5ad3-41dd-a975-4b1d9fb788a3	70de40ee-3931-4fd7-b4c0-278ebe1ab2a3	c8c029e5-7dca-4cd0-b4af-a960178371ba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 09:23:43	2024-05-02 09:23:43
08af0f18-1615-4d26-ac9d-6ccfa1cab2c1	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 09:24:30	2024-05-02 09:24:30
cf73e5dc-1955-4992-bbc9-53efb5b396d2	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	3e2e9ef1-7cba-403d-944f-52684449a161	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 09:24:33	2024-05-02 09:24:33
59cddf51-ebc8-46ac-994d-96f12dd79f07	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	12d00c01-4e99-4706-aa29-56db101d5f55	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 09:24:36	2024-05-02 09:24:36
bbf7a995-9033-4eb5-95fa-2efe0c4ac5a2	ffc3f0aa-ff3b-4115-a1d1-15ce8f12b64b	c8c029e5-7dca-4cd0-b4af-a960178371ba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 09:24:39	2024-05-02 09:24:39
6dec073f-6e1a-4287-8ee0-aa30da10a467	b102c7a6-2991-4c49-95c9-200e06d2c9bb	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	pass	2024-05-02 11:42:17	2024-05-02 11:42:17
1bc3e038-ecd1-4cda-8a22-0f1f1c82fa15	b102c7a6-2991-4c49-95c9-200e06d2c9bb	3e2e9ef1-7cba-403d-944f-52684449a161	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	fail	2024-05-02 11:42:20	2024-05-02 11:42:20
bff7fbd4-04a2-44f5-862f-b22d7f46972a	b102c7a6-2991-4c49-95c9-200e06d2c9bb	12d00c01-4e99-4706-aa29-56db101d5f55	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	fail	2024-05-02 11:42:23	2024-05-02 11:42:23
8195e153-b0bb-456a-8f05-2eed08907cea	b102c7a6-2991-4c49-95c9-200e06d2c9bb	c8c029e5-7dca-4cd0-b4af-a960178371ba	eeccc256-5c38-4c2f-9ef9-2134fd74f87a	fail	2024-05-02 11:42:26	2024-05-02 11:42:26
fc236760-e2a5-4e6a-bbc5-8ddd056c6f8c	e6a99d0c-7077-49b8-883d-2fafbf391805	7cb4f6d1-7a23-47c1-8d58-a7000eecc811	e7599eb1-f783-4b01-ae67-1e6cb683c61b	pass	2024-05-02 11:43:06	2024-05-02 11:43:06
a187d82a-5058-4323-aed0-70046df33d4e	e6a99d0c-7077-49b8-883d-2fafbf391805	3e2e9ef1-7cba-403d-944f-52684449a161	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 11:43:09	2024-05-02 11:43:09
bdc30313-8a98-448f-a993-a508b7a23d10	e6a99d0c-7077-49b8-883d-2fafbf391805	12d00c01-4e99-4706-aa29-56db101d5f55	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 11:43:12	2024-05-02 11:43:12
b84316c0-41e3-487d-a4c7-45ad32f43dc0	e6a99d0c-7077-49b8-883d-2fafbf391805	c8c029e5-7dca-4cd0-b4af-a960178371ba	e7599eb1-f783-4b01-ae67-1e6cb683c61b	fail	2024-05-02 11:43:15	2024-05-02 11:43:15
\.


--
-- Data for Name: universities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.universities (id, name, student_email_regex, inserted_at, updated_at, timezone) FROM stdin;
3ba3ec16-1728-4a82-8e46-a3deaef81ec4	University Of Limerick	^\\d+@studentmail.ul.ie$	2024-05-02 07:47:00	2024-05-02 07:47:00	Europe/Dublin
10e40b17-3597-41ed-93c2-68767fc1e4f3	University College Cork	^\\d+@studentmail.ucc.ie$	2024-05-02 07:47:00	2024-05-02 07:47:00	Europe/Dublin
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, role, inserted_at, updated_at, university_id) FROM stdin;
d1248f86-29ad-40e5-ad45-6cffcbb34cb8	admin@handin.org	$2b$12$rCXztsFHNQCzuauiyU2pAeWA4ZdAFKgbmhwVYN9YhnxrmLYaa4YC6	2024-05-02 07:47:00	admin	2024-05-02 07:47:01	2024-05-02 07:47:01	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
059fb847-1d6a-4876-9d49-81106d2d8891	paddy@ul.ie	$2b$12$GnD0YJ76vj84W1ISQ9l0veMQ5W08XsOZ4QzaQ5mYSIFWF4RMnNeni	2024-05-02 07:47:00	lecturer	2024-05-02 07:47:01	2024-05-02 07:47:01	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
eeccc256-5c38-4c2f-9ef9-2134fd74f87a	1@studentmail.ul.ie	$2b$12$RWHccoKDcBss3qWrgE4Q9uMj2vBoGjMHA2HeaSAkBys3e7s3lqXZ.	2024-05-02 07:47:00	student	2024-05-02 07:47:01	2024-05-02 07:47:01	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
e7599eb1-f783-4b01-ae67-1e6cb683c61b	2@studentmail.ul.ie	$2b$12$Gf9kqhLxZrPO0n2mIOUNFu7PGTJH4aItS2EpXNQQ5RVYDVx4J/dIm	2024-05-02 07:47:00	student	2024-05-02 07:47:01	2024-05-02 07:47:01	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
62b4ccd4-fe16-436c-88ad-54e9fcbb0b96	3@studentmail.ul.ie	$2b$12$HHMXc.qg3Lu6lhWRfpxrEOiPE5DrPX.S1UiE//N1PT0ShijMXUl3K	2024-05-02 07:47:00	student	2024-05-02 07:47:01	2024-05-02 07:47:01	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
521ae012-c22b-4944-955d-35ebb81f8a9c	4@studentmail.ul.ie	$2b$12$e059Igt0ga11S5Mm6EjnP.0FPhiRhszMNv4pChJJbliMYvgKzM0SS	2024-05-02 07:47:00	student	2024-05-02 07:47:02	2024-05-02 07:47:02	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
1d8606da-3906-4dd8-9864-d7ca100c5161	5@studentmail.ul.ie	$2b$12$o4J0DtQ7.4qEQ84nQKvzX.ebVYrfMP4wB/lnLZHaty6va4ELfdMWK	2024-05-02 07:47:00	student	2024-05-02 07:47:02	2024-05-02 07:47:02	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
2f0b1354-47a1-4a4c-ac8e-552ebe9e535c	6@studentmail.ul.ie	$2b$12$IQHHD/y57e3Tbqj44OBlX.Qy2pCrpwxXHuxdHJTCP2ya4i2YDh4TO	2024-05-02 07:47:00	student	2024-05-02 07:47:02	2024-05-02 07:47:02	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
b629ab30-2a31-4806-af38-bdde388d698f	7@studentmail.ul.ie	$2b$12$XVaLIm2ugFTULO8HMReqw.1C2mr3uASUf7QyE7ZicJIMqvNXruZFe	2024-05-02 07:47:00	student	2024-05-02 07:47:02	2024-05-02 07:47:02	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
fe530f36-3677-46cc-bdf7-390dc099f211	8@studentmail.ul.ie	$2b$12$csE3X0c5mk/xLAZKuRR/BeaSjhc1S2WdINviEuX8y0t6DrhkNov3y	2024-05-02 07:47:00	student	2024-05-02 07:47:02	2024-05-02 07:47:02	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
14efdd07-8079-4218-90a9-28ab17600d3f	9@studentmail.ul.ie	$2b$12$nl.24Ir3Aaif5b5xWmqsiOffGfqT/SrYhTMfDQkfkeclyXW4Bxgii	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
a5b5514b-13c4-4017-a6e6-0d72afeb4b4c	10@studentmail.ul.ie	$2b$12$qejQCfTvRGRQW674zbtt0.wgBHvrqcSBZ182tPQ/EUlE/mO/8cXhe	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
be348edc-3c57-4b03-92a0-8f7607192438	11@studentmail.ul.ie	$2b$12$vi3571ej9olQf9pkLamdSOnPecH1TTmmdrMhMBoL9VGa0GRbu1/GW	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
1f4b5535-4ad1-48b8-9b88-ce793b9beafd	12@studentmail.ul.ie	$2b$12$72n5bEnxmLZJT0NyI/FCZuZJEPGsdgJ9bFmL1mBK.npfL6oT87TjW	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
05cca4ab-c116-4191-b524-af6773006ee8	13@studentmail.ul.ie	$2b$12$XahBrtHn2QpIAVkwERuVwezRpaNdpGJ.ciBdaMq54RJcVAa4Ro2iq	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
549a7f6f-9419-4388-ad04-cd211976c88b	14@studentmail.ul.ie	$2b$12$LnKlFgG3d.aW0n.FuAKmAuISwyKGrg4CFQPSBIaDeB2LquD8RMOzm	2024-05-02 07:47:00	student	2024-05-02 07:47:03	2024-05-02 07:47:03	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
61d86648-714e-4769-963f-989de17be1e6	15@studentmail.ul.ie	$2b$12$KrZ/ImIAQ4QJUt3Vmr/JNeVbu.dwQmR3FAAPyBOLOEn5fCtx4Vtvy	2024-05-02 07:47:00	student	2024-05-02 07:47:04	2024-05-02 07:47:04	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
f262d130-10bd-4036-bf74-da4477037502	16@studentmail.ul.ie	$2b$12$dR7wgBGPQ1LUJCDsKlo2UuRbqgzd31omjgbELywCjiZekxHmPN1oC	2024-05-02 07:47:00	student	2024-05-02 07:47:04	2024-05-02 07:47:04	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
9daa4dbe-bad4-44f6-8822-6f00eba45755	17@studentmail.ul.ie	$2b$12$9UUywjjSZyL4QExvti91veBx3jBj0CPVL0nIcmO7/wgaBQJA8h8K.	2024-05-02 07:47:00	student	2024-05-02 07:47:04	2024-05-02 07:47:04	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
3b3cf879-527e-4e14-80a9-4c87a1ca023d	18@studentmail.ul.ie	$2b$12$jRig8.9LeDsXV.GWTvbpVe.mBOuljkFfDKptqYynx6niALujI4MP6	2024-05-02 07:47:00	student	2024-05-02 07:47:04	2024-05-02 07:47:04	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
9cfba96f-cb93-41af-aba5-cf0a5a0b69ad	19@studentmail.ul.ie	$2b$12$t9n9XFtLnFcXSotO3AGNT.zmVYudKqHDWctRyf8QkgsMnIDSoSrfG	2024-05-02 07:47:00	student	2024-05-02 07:47:04	2024-05-02 07:47:04	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
a75d9b97-166b-41a9-b82a-573a945b275f	20@studentmail.ul.ie	$2b$12$jzF4fL6KPN0iZXKrAHRQYeOIBKLfIHZW6DMuqg31p42WdCKP6XH.i	2024-05-02 07:47:00	student	2024-05-02 07:47:05	2024-05-02 07:47:05	3ba3ec16-1728-4a82-8e46-a3deaef81ec4
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
e4443c00-e39f-46e5-944a-f97ba8ca6caf	d1248f86-29ad-40e5-ad45-6cffcbb34cb8	\\x2d4d2e9a8ac852d9d74b709a73ae637bfae8177d0f64b26166b5c84e06b8e4e9	session	\N	2024-05-02 11:46:11
\.


--
-- Name: assignment_submission_files assignment_submission_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submission_files
    ADD CONSTRAINT assignment_submission_files_pkey PRIMARY KEY (id);


--
-- Name: assignment_submission_tests assignment_submission_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submission_tests
    ADD CONSTRAINT assignment_submission_tests_pkey PRIMARY KEY (id);


--
-- Name: assignment_submissions_builds assignment_submissions_builds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions_builds
    ADD CONSTRAINT assignment_submissions_builds_pkey PRIMARY KEY (id);


--
-- Name: assignment_submissions assignment_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions
    ADD CONSTRAINT assignment_submissions_pkey PRIMARY KEY (id);


--
-- Name: assignment_tests assignment_tests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_tests
    ADD CONSTRAINT assignment_tests_pkey PRIMARY KEY (id);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: builds builds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_pkey PRIMARY KEY (id);


--
-- Name: custom_assignment_dates custom_assignment_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_assignment_dates
    ADD CONSTRAINT custom_assignment_dates_pkey PRIMARY KEY (id);


--
-- Name: lecturer_assignment_submissions_builds lecturer_assignment_submissions_builds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_assignment_submissions_builds
    ADD CONSTRAINT lecturer_assignment_submissions_builds_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: module module_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.module
    ADD CONSTRAINT module_pkey PRIMARY KEY (id);


--
-- Name: modules_invitations modules_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules_invitations
    ADD CONSTRAINT modules_invitations_pkey PRIMARY KEY (id);


--
-- Name: modules_users modules_users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules_users
    ADD CONSTRAINT modules_users_pkey PRIMARY KEY (id);


--
-- Name: programming_languages programming_languages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.programming_languages
    ADD CONSTRAINT programming_languages_pkey PRIMARY KEY (id);


--
-- Name: run_script_results run_script_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run_script_results
    ADD CONSTRAINT run_script_results_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: solution_files solution_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solution_files
    ADD CONSTRAINT solution_files_pkey PRIMARY KEY (id);


--
-- Name: test_results test_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_pkey PRIMARY KEY (id);


--
-- Name: support_files test_support_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_files
    ADD CONSTRAINT test_support_files_pkey PRIMARY KEY (id);


--
-- Name: universities universities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.universities
    ADD CONSTRAINT universities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: assignment_submission_files_assignment_submission_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_submission_files_assignment_submission_id_index ON public.assignment_submission_files USING btree (assignment_submission_id);


--
-- Name: assignment_submission_tests_assignment_submission_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_submission_tests_assignment_submission_id_index ON public.assignment_submission_tests USING btree (assignment_submission_id);


--
-- Name: assignment_submission_tests_assignment_test_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_submission_tests_assignment_test_id_index ON public.assignment_submission_tests USING btree (assignment_test_id);


--
-- Name: assignment_submissions_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_submissions_assignment_id_index ON public.assignment_submissions USING btree (assignment_id);


--
-- Name: assignment_submissions_builds_assignment_submission_id_build_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX assignment_submissions_builds_assignment_submission_id_build_id ON public.assignment_submissions_builds USING btree (assignment_submission_id, build_id);


--
-- Name: assignment_submissions_user_id_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX assignment_submissions_user_id_assignment_id_index ON public.assignment_submissions USING btree (user_id, assignment_id);


--
-- Name: assignment_submissions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_submissions_user_id_index ON public.assignment_submissions USING btree (user_id);


--
-- Name: assignment_tests_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignment_tests_assignment_id_index ON public.assignment_tests USING btree (assignment_id);


--
-- Name: assignments_module_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignments_module_id_index ON public.assignments USING btree (module_id);


--
-- Name: assignments_programming_language_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX assignments_programming_language_id_index ON public.assignments USING btree (programming_language_id);


--
-- Name: builds_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX builds_assignment_id_index ON public.builds USING btree (assignment_id);


--
-- Name: builds_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX builds_user_id_index ON public.builds USING btree (user_id);


--
-- Name: custom_assignment_dates_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_assignment_dates_assignment_id_index ON public.custom_assignment_dates USING btree (assignment_id);


--
-- Name: custom_assignment_dates_assignment_id_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX custom_assignment_dates_assignment_id_user_id_index ON public.custom_assignment_dates USING btree (assignment_id, user_id);


--
-- Name: custom_assignment_dates_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX custom_assignment_dates_user_id_index ON public.custom_assignment_dates USING btree (user_id);


--
-- Name: lecturer_assignment_submissions_builds_assignment_submission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX lecturer_assignment_submissions_builds_assignment_submission_id ON public.lecturer_assignment_submissions_builds USING btree (assignment_submission_id, build_id);


--
-- Name: logs_build_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX logs_build_id_index ON public.logs USING btree (build_id);


--
-- Name: modules_invitations_email_module_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX modules_invitations_email_module_id_index ON public.modules_invitations USING btree (email, module_id);


--
-- Name: modules_users_module_id_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX modules_users_module_id_user_id_index ON public.modules_users USING btree (module_id, user_id);


--
-- Name: run_script_results_build_id_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX run_script_results_build_id_assignment_id_index ON public.run_script_results USING btree (build_id, assignment_id);


--
-- Name: solution_files_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX solution_files_assignment_id_index ON public.solution_files USING btree (assignment_id);


--
-- Name: support_files_assignment_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX support_files_assignment_id_index ON public.support_files USING btree (assignment_id);


--
-- Name: test_results_build_id_assignment_test_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX test_results_build_id_assignment_test_id_index ON public.test_results USING btree (build_id, assignment_test_id);


--
-- Name: universities_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX universities_name_index ON public.universities USING btree (name);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: users_university_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_university_id_index ON public.users USING btree (university_id);


--
-- Name: assignment_submission_files assignment_submission_files_assignment_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submission_files
    ADD CONSTRAINT assignment_submission_files_assignment_submission_id_fkey FOREIGN KEY (assignment_submission_id) REFERENCES public.assignment_submissions(id);


--
-- Name: assignment_submission_tests assignment_submission_tests_assignment_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submission_tests
    ADD CONSTRAINT assignment_submission_tests_assignment_submission_id_fkey FOREIGN KEY (assignment_submission_id) REFERENCES public.assignment_submissions(id);


--
-- Name: assignment_submission_tests assignment_submission_tests_assignment_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submission_tests
    ADD CONSTRAINT assignment_submission_tests_assignment_test_id_fkey FOREIGN KEY (assignment_test_id) REFERENCES public.assignment_tests(id);


--
-- Name: assignment_submissions assignment_submissions_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions
    ADD CONSTRAINT assignment_submissions_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: assignment_submissions_builds assignment_submissions_builds_assignment_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions_builds
    ADD CONSTRAINT assignment_submissions_builds_assignment_submission_id_fkey FOREIGN KEY (assignment_submission_id) REFERENCES public.assignment_submissions(id) ON DELETE CASCADE;


--
-- Name: assignment_submissions_builds assignment_submissions_builds_build_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions_builds
    ADD CONSTRAINT assignment_submissions_builds_build_id_fkey FOREIGN KEY (build_id) REFERENCES public.builds(id) ON DELETE CASCADE;


--
-- Name: assignment_submissions assignment_submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_submissions
    ADD CONSTRAINT assignment_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: assignment_tests assignment_tests_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignment_tests
    ADD CONSTRAINT assignment_tests_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: assignments assignments_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.module(id);


--
-- Name: assignments assignments_programming_language_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.assignments
    ADD CONSTRAINT assignments_programming_language_id_fkey FOREIGN KEY (programming_language_id) REFERENCES public.programming_languages(id);


--
-- Name: builds builds_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE;


--
-- Name: builds builds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.builds
    ADD CONSTRAINT builds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: custom_assignment_dates custom_assignment_dates_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_assignment_dates
    ADD CONSTRAINT custom_assignment_dates_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE;


--
-- Name: custom_assignment_dates custom_assignment_dates_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_assignment_dates
    ADD CONSTRAINT custom_assignment_dates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: lecturer_assignment_submissions_builds lecturer_assignment_submissions_builds_assignment_submission_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_assignment_submissions_builds
    ADD CONSTRAINT lecturer_assignment_submissions_builds_assignment_submission_id FOREIGN KEY (assignment_submission_id) REFERENCES public.assignment_submissions(id) ON DELETE CASCADE;


--
-- Name: lecturer_assignment_submissions_builds lecturer_assignment_submissions_builds_build_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lecturer_assignment_submissions_builds
    ADD CONSTRAINT lecturer_assignment_submissions_builds_build_id_fkey FOREIGN KEY (build_id) REFERENCES public.builds(id) ON DELETE CASCADE;


--
-- Name: logs logs_assignment_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_assignment_test_id_fkey FOREIGN KEY (assignment_test_id) REFERENCES public.assignment_tests(id) ON DELETE CASCADE;


--
-- Name: logs logs_build_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_build_id_fkey FOREIGN KEY (build_id) REFERENCES public.builds(id) ON DELETE CASCADE;


--
-- Name: modules_invitations modules_invitations_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules_invitations
    ADD CONSTRAINT modules_invitations_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.module(id);


--
-- Name: modules_users modules_users_module_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules_users
    ADD CONSTRAINT modules_users_module_id_fkey FOREIGN KEY (module_id) REFERENCES public.module(id) ON DELETE CASCADE;


--
-- Name: modules_users modules_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules_users
    ADD CONSTRAINT modules_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: run_script_results run_script_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run_script_results
    ADD CONSTRAINT run_script_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: run_script_results run_script_results_build_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run_script_results
    ADD CONSTRAINT run_script_results_build_id_fkey FOREIGN KEY (build_id) REFERENCES public.builds(id);


--
-- Name: run_script_results run_script_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.run_script_results
    ADD CONSTRAINT run_script_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: solution_files solution_files_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.solution_files
    ADD CONSTRAINT solution_files_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: support_files support_files_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_files
    ADD CONSTRAINT support_files_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.assignments(id);


--
-- Name: test_results test_results_assignment_test_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_assignment_test_id_fkey FOREIGN KEY (assignment_test_id) REFERENCES public.assignment_tests(id) ON DELETE CASCADE;


--
-- Name: test_results test_results_build_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_build_id_fkey FOREIGN KEY (build_id) REFERENCES public.builds(id);


--
-- Name: test_results test_results_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.test_results
    ADD CONSTRAINT test_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_university_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.universities(id);


--
-- PostgreSQL database dump complete
--


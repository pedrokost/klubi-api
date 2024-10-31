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
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: update_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.update_status AS ENUM (
    'unverified',
    'accepted',
    'rejected'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_requests (
    id bigint NOT NULL,
    commentable_type character varying,
    commentable_id bigint,
    requester_email character varying,
    requester_name character varying,
    commenter_email character varying,
    commenter_name character varying,
    request_hash character varying,
    comment_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_requests_id_seq OWNED BY public.comment_requests.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    commentable_type character varying,
    commentable_id bigint,
    body character varying,
    commenter_email character varying,
    commenter_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: email_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_stats (
    id integer NOT NULL,
    email character varying NOT NULL,
    last_opened_at timestamp without time zone,
    last_clicked_at timestamp without time zone,
    last_bounced_at timestamp without time zone,
    last_dropped_at timestamp without time zone,
    last_delivered_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_stats_id_seq OWNED BY public.email_stats.id;


--
-- Name: klubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.klubs (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    address character varying,
    town character varying,
    website character varying,
    phone character varying,
    email character varying,
    latitude numeric(10,6),
    longitude numeric(10,6),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    complete boolean DEFAULT false,
    categories character varying[] DEFAULT '{}'::character varying[],
    facebook_url character varying,
    editor_emails character varying[] DEFAULT '{}'::character varying[],
    parent_id integer,
    verified boolean DEFAULT false,
    notes character varying,
    last_verification_reminder_at timestamp without time zone,
    closed_at date,
    description character varying,
    visits_count integer DEFAULT 0,
    visits_count_updated_at timestamp without time zone,
    data_confirmed_at timestamp without time zone,
    data_confirmation_request_hash character varying
);


--
-- Name: klubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.klubs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: klubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.klubs_id_seq OWNED BY public.klubs.id;


--
-- Name: obcinas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obcinas (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    population_size integer,
    geom public.geography(MultiPolygon,4326),
    statisticna_regija_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: obcinas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.obcinas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: obcinas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.obcinas_id_seq OWNED BY public.obcinas.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: statisticna_regijas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.statisticna_regijas (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    population_size integer,
    geom public.geography(MultiPolygon,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: statisticna_regijas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.statisticna_regijas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statisticna_regijas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.statisticna_regijas_id_seq OWNED BY public.statisticna_regijas.id;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.updates (
    id integer NOT NULL,
    updatable_type character varying NOT NULL,
    updatable_id integer NOT NULL,
    field character varying NOT NULL,
    oldvalue character varying,
    newvalue character varying,
    status public.update_status DEFAULT 'unverified'::public.update_status,
    editor_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    acceptance_email_sent boolean DEFAULT false
);


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.updates_id_seq OWNED BY public.updates.id;


--
-- Name: comment_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_requests ALTER COLUMN id SET DEFAULT nextval('public.comment_requests_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: email_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_stats ALTER COLUMN id SET DEFAULT nextval('public.email_stats_id_seq'::regclass);


--
-- Name: klubs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klubs ALTER COLUMN id SET DEFAULT nextval('public.klubs_id_seq'::regclass);


--
-- Name: obcinas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obcinas ALTER COLUMN id SET DEFAULT nextval('public.obcinas_id_seq'::regclass);


--
-- Name: statisticna_regijas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statisticna_regijas ALTER COLUMN id SET DEFAULT nextval('public.statisticna_regijas_id_seq'::regclass);


--
-- Name: updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.updates ALTER COLUMN id SET DEFAULT nextval('public.updates_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comment_requests comment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_requests
    ADD CONSTRAINT comment_requests_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: email_stats email_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_stats
    ADD CONSTRAINT email_stats_pkey PRIMARY KEY (id);


--
-- Name: klubs klubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.klubs
    ADD CONSTRAINT klubs_pkey PRIMARY KEY (id);


--
-- Name: obcinas obcinas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obcinas
    ADD CONSTRAINT obcinas_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: statisticna_regijas statisticna_regijas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.statisticna_regijas
    ADD CONSTRAINT statisticna_regijas_pkey PRIMARY KEY (id);


--
-- Name: updates updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_comment_request_unique_commenter_commentable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_request_unique_commenter_commentable ON public.comment_requests USING btree (commentable_type, commentable_id, commenter_email);


--
-- Name: index_comment_requests_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_comment_id ON public.comment_requests USING btree (comment_id);


--
-- Name: index_comment_requests_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_commentable_type_and_commentable_id ON public.comment_requests USING btree (commentable_type, commentable_id);


--
-- Name: index_comment_requests_on_request_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_request_hash ON public.comment_requests USING btree (request_hash);


--
-- Name: index_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_type_and_commentable_id ON public.comments USING btree (commentable_type, commentable_id);


--
-- Name: index_email_stats_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_stats_on_email ON public.email_stats USING btree (email);


--
-- Name: index_klubs_on_categories; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_categories ON public.klubs USING gin (categories);


--
-- Name: index_klubs_on_editor_emails; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_editor_emails ON public.klubs USING gin (editor_emails);


--
-- Name: index_klubs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_parent_id ON public.klubs USING btree (parent_id);


--
-- Name: index_klubs_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_slug ON public.klubs USING btree (slug);


--
-- Name: index_obcinas_on_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_obcinas_on_geom ON public.obcinas USING gist (geom);


--
-- Name: index_obcinas_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_obcinas_on_slug ON public.obcinas USING btree (slug);


--
-- Name: index_obcinas_on_statisticna_regija_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_obcinas_on_statisticna_regija_id ON public.obcinas USING btree (statisticna_regija_id);


--
-- Name: index_on_klubs_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_klubs_location ON public.klubs USING gist (public.st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_statisticna_regijas_on_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statisticna_regijas_on_geom ON public.statisticna_regijas USING gist (geom);


--
-- Name: index_statisticna_regijas_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_statisticna_regijas_on_slug ON public.statisticna_regijas USING btree (slug);


--
-- Name: index_updates_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_status ON public.updates USING btree (status);


--
-- Name: index_updates_on_updatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_updatable_id ON public.updates USING btree (updatable_id);


--
-- Name: index_updates_on_updatable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_updatable_type ON public.updates USING btree (updatable_type);


--
-- Name: obcinas fk_rails_439801d288; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obcinas
    ADD CONSTRAINT fk_rails_439801d288 FOREIGN KEY (statisticna_regija_id) REFERENCES public.statisticna_regijas(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20141126203513'),
('20141127220853'),
('20141127221214'),
('20141130183820'),
('20141207092059'),
('20141213175601'),
('20150405101024'),
('20150822135854'),
('20151129142053'),
('20160703105120'),
('20160707185547'),
('20161127143702'),
('20170107115719'),
('20170114173733'),
('20170514142319'),
('20170516202345'),
('20170518201248'),
('20170518210754'),
('20170614201058'),
('20171029112020'),
('20171029141942'),
('20171118175221'),
('20171118180158'),
('20180204185203'),
('20180211111013');



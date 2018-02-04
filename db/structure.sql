SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: update_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE update_status AS ENUM (
    'unverified',
    'accepted',
    'rejected'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: comment_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comment_requests (
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

CREATE SEQUENCE comment_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comment_requests_id_seq OWNED BY comment_requests.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
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

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
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

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: email_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE email_stats (
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

CREATE SEQUENCE email_stats_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_stats_id_seq OWNED BY email_stats.id;


--
-- Name: klubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE klubs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    address character varying(255),
    town character varying(255),
    website character varying(255),
    phone character varying(255),
    email character varying(255),
    latitude numeric(10,6),
    longitude numeric(10,6),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    complete boolean DEFAULT false,
    categories character varying(255)[] DEFAULT '{}'::character varying[],
    facebook_url character varying(255),
    editor_emails character varying(255)[] DEFAULT '{}'::character varying[],
    parent_id integer,
    verified boolean DEFAULT false,
    notes character varying,
    last_verification_reminder_at timestamp without time zone,
    closed_at date,
    description character varying,
    visits_count integer DEFAULT 0,
    visits_count_updated_at timestamp without time zone
);


--
-- Name: klubs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE klubs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: klubs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE klubs_id_seq OWNED BY klubs.id;


--
-- Name: obcinas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE obcinas (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    population_size integer,
    geom geography(MultiPolygon,4326),
    statisticna_regija_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: obcinas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE obcinas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: obcinas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE obcinas_id_seq OWNED BY obcinas.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: statisticna_regijas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE statisticna_regijas (
    id integer NOT NULL,
    name character varying NOT NULL,
    slug character varying NOT NULL,
    population_size integer,
    geom geography(MultiPolygon,4326),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: statisticna_regijas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statisticna_regijas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statisticna_regijas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statisticna_regijas_id_seq OWNED BY statisticna_regijas.id;


--
-- Name: statisticne_regije_test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE statisticne_regije_test (
    gid integer NOT NULL,
    sr_ime character varying(30),
    tot_p character varying(80),
    v4155 character varying(80),
    __gid numeric(10,0),
    geom geometry(MultiPolygon,4326)
);


--
-- Name: statisticne_regije_test_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statisticne_regije_test_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statisticne_regije_test_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statisticne_regije_test_gid_seq OWNED BY statisticne_regije_test.gid;


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE updates (
    id integer NOT NULL,
    updatable_type character varying NOT NULL,
    updatable_id integer NOT NULL,
    field character varying NOT NULL,
    oldvalue character varying,
    newvalue character varying,
    status update_status DEFAULT 'unverified'::update_status,
    editor_email character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    acceptance_email_sent boolean DEFAULT false
);


--
-- Name: updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE updates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE updates_id_seq OWNED BY updates.id;


--
-- Name: zatresi-api_development; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "zatresi-api_development" (
    gid integer NOT NULL,
    sr_ime character varying(30),
    tot_p character varying(80),
    v4155 character varying(80),
    __gid numeric(10,0),
    geom geometry(MultiPolygon,3912)
);


--
-- Name: zatresi-api_development_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "zatresi-api_development_gid_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: zatresi-api_development_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "zatresi-api_development_gid_seq" OWNED BY "zatresi-api_development".gid;


--
-- Name: comment_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_requests ALTER COLUMN id SET DEFAULT nextval('comment_requests_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: email_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_stats ALTER COLUMN id SET DEFAULT nextval('email_stats_id_seq'::regclass);


--
-- Name: klubs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY klubs ALTER COLUMN id SET DEFAULT nextval('klubs_id_seq'::regclass);


--
-- Name: obcinas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY obcinas ALTER COLUMN id SET DEFAULT nextval('obcinas_id_seq'::regclass);


--
-- Name: statisticna_regijas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statisticna_regijas ALTER COLUMN id SET DEFAULT nextval('statisticna_regijas_id_seq'::regclass);


--
-- Name: statisticne_regije_test gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statisticne_regije_test ALTER COLUMN gid SET DEFAULT nextval('statisticne_regije_test_gid_seq'::regclass);


--
-- Name: updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: zatresi-api_development gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "zatresi-api_development" ALTER COLUMN gid SET DEFAULT nextval('"zatresi-api_development_gid_seq"'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: comment_requests comment_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comment_requests
    ADD CONSTRAINT comment_requests_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: email_stats email_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_stats
    ADD CONSTRAINT email_stats_pkey PRIMARY KEY (id);


--
-- Name: klubs klubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY klubs
    ADD CONSTRAINT klubs_pkey PRIMARY KEY (id);


--
-- Name: obcinas obcinas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY obcinas
    ADD CONSTRAINT obcinas_pkey PRIMARY KEY (id);


--
-- Name: statisticna_regijas statisticna_regijas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statisticna_regijas
    ADD CONSTRAINT statisticna_regijas_pkey PRIMARY KEY (id);


--
-- Name: statisticne_regije_test statisticne_regije_test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statisticne_regije_test
    ADD CONSTRAINT statisticne_regije_test_pkey PRIMARY KEY (gid);


--
-- Name: updates updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: zatresi-api_development zatresi-api_development_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "zatresi-api_development"
    ADD CONSTRAINT "zatresi-api_development_pkey" PRIMARY KEY (gid);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_comment_request_unique_commenter_commentable; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_request_unique_commenter_commentable ON comment_requests USING btree (commentable_type, commentable_id, commenter_email);


--
-- Name: index_comment_requests_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_comment_id ON comment_requests USING btree (comment_id);


--
-- Name: index_comment_requests_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_commentable_type_and_commentable_id ON comment_requests USING btree (commentable_type, commentable_id);


--
-- Name: index_comment_requests_on_request_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_requests_on_request_hash ON comment_requests USING btree (request_hash);


--
-- Name: index_comments_on_commentable_type_and_commentable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_commentable_type_and_commentable_id ON comments USING btree (commentable_type, commentable_id);


--
-- Name: index_email_stats_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_email_stats_on_email ON email_stats USING btree (email);


--
-- Name: index_klubs_on_categories; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_categories ON klubs USING gin (categories);


--
-- Name: index_klubs_on_editor_emails; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_editor_emails ON klubs USING gin (editor_emails);


--
-- Name: index_klubs_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_parent_id ON klubs USING btree (parent_id);


--
-- Name: index_klubs_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_klubs_on_slug ON klubs USING btree (slug);


--
-- Name: index_obcinas_on_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_obcinas_on_geom ON obcinas USING gist (geom);


--
-- Name: index_obcinas_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_obcinas_on_slug ON obcinas USING btree (slug);


--
-- Name: index_obcinas_on_statisticna_regija_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_obcinas_on_statisticna_regija_id ON obcinas USING btree (statisticna_regija_id);


--
-- Name: index_on_klubs_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_on_klubs_location ON klubs USING gist (st_geographyfromtext((((('SRID=4326;POINT('::text || longitude) || ' '::text) || latitude) || ')'::text)));


--
-- Name: index_statisticna_regijas_on_geom; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_statisticna_regijas_on_geom ON statisticna_regijas USING gist (geom);


--
-- Name: index_statisticna_regijas_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_statisticna_regijas_on_slug ON statisticna_regijas USING btree (slug);


--
-- Name: index_updates_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_status ON updates USING btree (status);


--
-- Name: index_updates_on_updatable_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_updatable_id ON updates USING btree (updatable_id);


--
-- Name: index_updates_on_updatable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_updates_on_updatable_type ON updates USING btree (updatable_type);


--
-- Name: statisticne_regije_test_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX statisticne_regije_test_geom_idx ON statisticne_regije_test USING gist (geom);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: zatresi-api_development_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "zatresi-api_development_geom_idx" ON "zatresi-api_development" USING gist (geom);


--
-- Name: obcinas fk_rails_439801d288; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY obcinas
    ADD CONSTRAINT fk_rails_439801d288 FOREIGN KEY (statisticna_regija_id) REFERENCES statisticna_regijas(id);


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
('20180204185203');



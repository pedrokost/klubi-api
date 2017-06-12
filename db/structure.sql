--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

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
    closed_at date
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

INSERT INTO schema_migrations (version) VALUES ('20141126203513');

INSERT INTO schema_migrations (version) VALUES ('20141127220853');

INSERT INTO schema_migrations (version) VALUES ('20141127221214');

INSERT INTO schema_migrations (version) VALUES ('20141130183820');

INSERT INTO schema_migrations (version) VALUES ('20141207092059');

INSERT INTO schema_migrations (version) VALUES ('20141213175601');

INSERT INTO schema_migrations (version) VALUES ('20150405101024');

INSERT INTO schema_migrations (version) VALUES ('20150822135854');

INSERT INTO schema_migrations (version) VALUES ('20151129142053');

INSERT INTO schema_migrations (version) VALUES ('20160703105120');

INSERT INTO schema_migrations (version) VALUES ('20160707185547');

INSERT INTO schema_migrations (version) VALUES ('20161127143702');

INSERT INTO schema_migrations (version) VALUES ('20170107115719');

INSERT INTO schema_migrations (version) VALUES ('20170114173733');

INSERT INTO schema_migrations (version) VALUES ('20170514142319');

INSERT INTO schema_migrations (version) VALUES ('20170516202345');

INSERT INTO schema_migrations (version) VALUES ('20170518201248');

INSERT INTO schema_migrations (version) VALUES ('20170518210754');

INSERT INTO schema_migrations (version) VALUES ('20170614201058');


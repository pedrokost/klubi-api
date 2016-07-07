--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


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
-- Name: klubs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    notes character varying
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: updates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    updated_at timestamp without time zone NOT NULL
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY klubs ALTER COLUMN id SET DEFAULT nextval('klubs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY updates ALTER COLUMN id SET DEFAULT nextval('updates_id_seq'::regclass);


--
-- Name: klubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY klubs
    ADD CONSTRAINT klubs_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (id);


--
-- Name: index_klubs_on_categories; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_klubs_on_categories ON klubs USING gin (categories);


--
-- Name: index_klubs_on_editor_emails; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_klubs_on_editor_emails ON klubs USING gin (editor_emails);


--
-- Name: index_klubs_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_klubs_on_parent_id ON klubs USING btree (parent_id);


--
-- Name: index_klubs_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_klubs_on_slug ON klubs USING btree (slug);


--
-- Name: index_updates_on_status; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_status ON updates USING btree (status);


--
-- Name: index_updates_on_updatable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_updatable_id ON updates USING btree (updatable_id);


--
-- Name: index_updates_on_updatable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_updates_on_updatable_type ON updates USING btree (updatable_type);


--
-- Name: klubs_categories; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX klubs_categories ON klubs USING btree (categories);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

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


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


SET search_path = public, pg_catalog;

--
-- Name: delayed_jobs_after_delete_row_tr_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delayed_jobs_after_delete_row_tr_fn() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        running_count integer;
      BEGIN
        IF OLD.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
          running_count := (SELECT COUNT(*) FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't');
          IF running_count < OLD.max_concurrent THEN
            UPDATE delayed_jobs SET next_in_strand = 't' WHERE id IN (
              SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
              j2.strand = OLD.strand ORDER BY j2.id ASC LIMIT (OLD.max_concurrent - running_count) FOR UPDATE
            );
          END IF;
        END IF;
        RETURN OLD;
      END;
      $$;


--
-- Name: delayed_jobs_before_insert_row_tr_fn(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION delayed_jobs_before_insert_row_tr_fn() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      BEGIN
        IF NEW.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(NEW.strand));
          IF (SELECT COUNT(*) FROM delayed_jobs WHERE strand = NEW.strand) >= NEW.max_concurrent THEN
            NEW.next_in_strand := 'f';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$;


--
-- Name: half_md5_as_bigint(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION half_md5_as_bigint(strand character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
      DECLARE
        strand_md5 bytea;
      BEGIN
        strand_md5 := decode(md5(strand), 'hex');
        RETURN (CAST(get_byte(strand_md5, 0) AS bigint) << 56) +
                                  (CAST(get_byte(strand_md5, 1) AS bigint) << 48) +
                                  (CAST(get_byte(strand_md5, 2) AS bigint) << 40) +
                                  (CAST(get_byte(strand_md5, 3) AS bigint) << 32) +
                                  (CAST(get_byte(strand_md5, 4) AS bigint) << 24) +
                                  (get_byte(strand_md5, 5) << 16) +
                                  (get_byte(strand_md5, 6) << 8) +
                                   get_byte(strand_md5, 7);
      END;
      $$;


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
-- Name: cached_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cached_subscriptions (
    id bigint NOT NULL,
    stripe_id character varying,
    customer_description character varying,
    customer_email character varying,
    status character varying,
    canceled_at timestamp without time zone,
    ended_at timestamp without time zone,
    start timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cached_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cached_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cached_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cached_subscriptions_id_seq OWNED BY cached_subscriptions.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    queue character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tag character varying(255),
    max_attempts integer,
    strand character varying(255),
    next_in_strand boolean DEFAULT true NOT NULL,
    source character varying(255),
    max_concurrent integer DEFAULT 1 NOT NULL,
    expires_at timestamp without time zone
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
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE failed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler character varying(512000),
    last_error text,
    queue character varying(255),
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tag character varying(255),
    max_attempts integer,
    strand character varying(255),
    original_job_id bigint,
    source character varying(255),
    expires_at timestamp without time zone
);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE failed_jobs_id_seq OWNED BY failed_jobs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: cached_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cached_subscriptions ALTER COLUMN id SET DEFAULT nextval('cached_subscriptions_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY failed_jobs ALTER COLUMN id SET DEFAULT nextval('failed_jobs_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: cached_subscriptions cached_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cached_subscriptions
    ADD CONSTRAINT cached_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: get_delayed_jobs_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX get_delayed_jobs_index ON delayed_jobs USING btree (priority, run_at, queue) WHERE ((locked_at IS NULL) AND (next_in_strand = true));


--
-- Name: index_delayed_jobs_on_locked_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_locked_by ON delayed_jobs USING btree (locked_by) WHERE (locked_by IS NOT NULL);


--
-- Name: index_delayed_jobs_on_run_at_and_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_run_at_and_tag ON delayed_jobs USING btree (run_at, tag);


--
-- Name: index_delayed_jobs_on_strand; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_strand ON delayed_jobs USING btree (strand, id);


--
-- Name: index_delayed_jobs_on_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delayed_jobs_on_tag ON delayed_jobs USING btree (tag);


--
-- Name: delayed_jobs delayed_jobs_after_delete_row_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delayed_jobs_after_delete_row_tr AFTER DELETE ON delayed_jobs FOR EACH ROW WHEN (((old.strand IS NOT NULL) AND (old.next_in_strand = true))) EXECUTE PROCEDURE delayed_jobs_after_delete_row_tr_fn();


--
-- Name: delayed_jobs delayed_jobs_before_insert_row_tr; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER delayed_jobs_before_insert_row_tr BEFORE INSERT ON delayed_jobs FOR EACH ROW WHEN ((new.strand IS NOT NULL)) EXECUTE PROCEDURE delayed_jobs_before_insert_row_tr_fn();


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20180408090153'),
('20180408090154'),
('20180408090155'),
('20180408090156'),
('20180408090157'),
('20180408090158'),
('20180408090159'),
('20180408090160'),
('20180408090161'),
('20180408090162'),
('20180408090163'),
('20180408090164'),
('20180408090165'),
('20180408090166'),
('20180408090167'),
('20180408090168'),
('20180408090169'),
('20180408090170'),
('20180408090171'),
('20180408090172'),
('20180408090173'),
('20180409031732');



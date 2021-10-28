CREATE EXTENSION IF NOT EXISTS timescaledb;

CREATE TABLE house_data (
    "timestamp" timestamp(3) with time zone NOT NULL,
    house_id integer NOT NULL,
    device_name character varying(256) NOT NULL,
    field text NOT NULL,
    value_decimal double precision,
    value_text text
);

CREATE TABLE alerts (
    "timestamp" timestamp(3) with time zone NOT NULL,
    house_id integer NOT NULL,
    device_name character varying(256) NOT NULL,
    message text NOT NULL
);

CREATE INDEX ON house_data (house_id, device_name, field, "timestamp" DESC);
CREATE INDEX ON house_data (house_id, device_name, "timestamp" DESC);
CREATE INDEX ON alerts (house_id, "timestamp" DESC);

SELECT create_hypertable('house_data','timestamp');
SELECT create_hypertable('alerts','timestamp');
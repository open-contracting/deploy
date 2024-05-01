DROP TABLE IF EXISTS cpc;

CREATE TABLE cpc (
    id serial,
    code text,
    description text,
    description_es text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ON cpc (code);

\copy cpc (code, description, description_es) from '{{ path }}' delimiter ',' csv header;

DROP TABLE IF EXISTS codelist;

CREATE TABLE codelist (
    id serial,
    codelist text,
    code text,
    code_es text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ON codelist (codelist, code);

\copy codelist (codelist, code, code_es) from '{{ path }}' delimiter ',' csv header;

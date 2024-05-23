DROP TABLE IF EXISTS codelist;

CREATE TABLE codelist (
    id serial PRIMARY KEY,
    codelist text,
    code text,
    code_es text,
    UNIQUE (codelist, code)
);

COPY codelist (codelist, code, code_es) from '{{ path }}' delimiter ',' csv header;

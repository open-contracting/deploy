DROP TABLE IF EXISTS cpc;

CREATE TABLE cpc (
    id serial PRIMARY KEY,
    code text UNIQUE, -- leading zeros
    description text,
    description_es text
);

COPY cpc (
    code, description, description_es
) FROM '{{ path }}' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS cpc;

CREATE TABLE cpc (
    id serial PRIMARY KEY,
    code text UNIQUE, -- leading zeros
    description text,
    description_es text
);

\copy cpc (code, description, description_es) from '{{ path }}' delimiter ',' csv header;

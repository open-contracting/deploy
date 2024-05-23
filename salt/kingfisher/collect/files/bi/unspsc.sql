DROP TABLE IF EXISTS unspsc;

CREATE TABLE unspsc (
    id serial PRIMARY KEY,
    code integer UNIQUE,
    description text,
    description_es text
);

\copy unspsc (code, description, description_es) from '{{ path }}' delimiter ',' csv header;

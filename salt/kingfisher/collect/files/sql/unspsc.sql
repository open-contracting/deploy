DROP TABLE IF EXISTS unspsc;

CREATE TABLE unspsc (
    id serial PRIMARY KEY,
    code integer UNIQUE,
    description text,
    description_es text
);

COPY unspsc (
    code, description, description_es
) FROM '{{ path }}' DELIMITER ',' CSV HEADER;

DROP TABLE IF EXISTS unspsc;

CREATE TABLE unspsc (
    id serial,
    code integer,
    description text,
    description_es text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ON unspsc (code);

\copy unspsc (code, description, description_es) from '{{ path }}' delimiter ',' csv header;

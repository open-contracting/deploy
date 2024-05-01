DROP TABLE IF EXISTS indicator;

CREATE TABLE indicator (
    id serial,
    code text,
    category text,
    title text,
    description text,
    category_es text,
    title_es text,
    description_es text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ON indicator (code);

\copy codelist (code, category, title, description, category_es, title_es, description_es) from '{{ path }}' delimiter ',' csv header;

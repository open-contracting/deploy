DROP TABLE IF EXISTS indicator;

CREATE TABLE indicator (
    id serial PRIMARY KEY,
    code text UNIQUE,
    category text,
    title text,
    description text,
    category_es text,
    title_es text,
    description_es text
);

COPY indicator (
    code, category, title, description, category_es, title_es, description_es
) FROM '{{ path }}' DELIMITER ',' CSV HEADER;

SET ROLE reference;

DROP TABLE IF EXISTS reference.mapping_sheets;

CREATE TABLE reference.mapping_sheets (
    id serial PRIMARY KEY,
    "version" text,
    "extension" text,
    section text,
    "path" text,
    title text,
    description text,
    "type" text,
    "range" text,
    "values" text,
    links text,
    deprecated text,
    "deprecationNotes" text
);

COPY reference.mapping_sheets (
    "version",
    "extension",
    section,
    "path",
    title,
    description,
    "type",
    "range",
    "values",
    links,
    deprecated,
    "deprecationNotes"
) FROM '{{ path }}' CSV HEADER;
SET ROLE NONE;

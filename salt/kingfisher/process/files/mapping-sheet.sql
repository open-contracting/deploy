DROP TABLE reference.mapping_sheets;

CREATE TABLE reference.mapping_sheets (
    id serial primary key,
    version text,
    extension text,
    section text,
    path text,
    title text,
    description text,
    type text,
    range text,
    values text,
    links text,
    deprecated text,
    "deprecationNotes" text
);

COPY reference.mapping_sheets (
    version,
    extension,
    section,
    path,
    title,
    description,
    type,
    range,
    values,
    links,
    deprecated,
    "deprecationNotes"
) FROM '{{ path }}' DELIMITER ',' CSV HEADER;

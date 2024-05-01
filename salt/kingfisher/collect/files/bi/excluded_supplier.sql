CREATE TABLE IF NOT EXISTS excluded_supplier (
    id serial,
    identifier text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX IF NOT EXISTS ON excluded_supplier (identifier);


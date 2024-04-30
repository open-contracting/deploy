-- Another process populates this table.
CREATE TABLE IF NOT EXISTS excluded_supplier (
    id serial,
    identifier text,
    PRIMARY KEY (id)
);

CREATE UNIQUE INDEX ON excluded_supplier (identifier);


CREATE TABLE IF NOT EXISTS excluded_supplier (
    id serial PRIMARY KEY,
    identifier text UNIQUE
);

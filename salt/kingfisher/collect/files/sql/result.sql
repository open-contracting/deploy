CREATE TABLE IF NOT EXISTS {{ spider }}_result (
    id serial PRIMARY KEY, -- an auto-incrementing ID that has no semantics
    ocid text, -- matches /ocid in the compiled release JSON
    -- the indicator's scope, one of OCID, Buyer, ProcuringEntity, Tenderer
    subject text,
    code text, -- the indicator's code
    result numeric, -- an individual indicator result
    buyer_id text, -- matches /buyer/id in the JSON
    procuring_entity_id text, -- matches /tender/procuringEntity/id in the JSON
    tenderer_id text, -- matches /bids/details[]/tenderers[]/id in the JSON
    created_at timestamp without time zone -- the time when this row was added
);

{%- for user in users %}
    GRANT SELECT ON {{ spider }}_result TO {{ user }};
{%- endfor %}

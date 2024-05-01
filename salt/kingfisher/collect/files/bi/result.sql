CREATE TABLE IF NOT EXISTS {{ spider }}_result (
    id serial, -- an auto-incrementing ID that has no semantics
    ocid text, -- matches /ocid in the compiled release JSON
    subject text, -- the indicator's scope, one of OCID, Buyer, ProcuringEntity, Tenderer
    code text, -- the indicator's code
    result numeric, -- an individual indicator result
    buyer_id text, -- matches /buyer/id in the JSON
    procuring_entity_id text, -- matches /tender/procuringEntity/id in the JSON
    tenderer_id text, -- matches /bids/details[]/tenderers[]/id in the JSON
    created_at timestamp without time zone, -- the time when this row was added
    PRIMARY KEY (id)
);


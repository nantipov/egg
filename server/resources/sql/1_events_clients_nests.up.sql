CREATE TABLE client_device (
    client_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE client_event (
    id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    client_id TEXT NOT NULL,
    color TEXT,
    is_input BOOLEAN NOT NULL,
    is_processed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE INDEX idx_clientevent_clientid ON nest(client_id);
CREATE INDEX idx_clientevent_inputprocessed ON nest(is_input, is_processed);

CREATE TABLE nest (
    nest_id TEXT PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE client_nest (
    id BIGSERIAL PRIMARY KEY,
    nest_id TEXT NOT NULL,
    client_id TEXT NOT NULL,
    color TEXT NOT NULL
);

CREATE UNIQUE INDEX idx_uniq_clientnest_nestclient ON client_nest(nest_id, client_id);
CREATE INDEX idx_clientnest_nest ON client_nest(nest_id);
CREATE INDEX idx_clientnest_client ON client_nest(client_id);

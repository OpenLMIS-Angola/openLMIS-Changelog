CREATE SCHEMA IF NOT EXISTS changelog;

CREATE TABLE IF NOT EXISTS changelog.data_changes (
    id SERIAL PRIMARY KEY,
    schema_name TEXT NOT NULL,
    table_name TEXT NOT NULL,
    operation CHAR(1) CHECK (operation IN ('I', 'U', 'D')),
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    row_data JSONB
);

CREATE OR REPLACE FUNCTION changelog.log_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO changelog.data_changes (schema_name, table_name, operation, row_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'I', row_to_json(NEW)::jsonb);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO changelog.data_changes (schema_name, table_name, operation, row_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'U', row_to_json(NEW)::jsonb);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO changelog.data_changes (schema_name, table_name, operation, row_data)
        VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, 'D', row_to_json(OLD)::jsonb);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;
-- ▼ TATA Foundation Database (432Hz)
-- PostgreSQL Initialization Script

CREATE DATABASE field_tata_truth;

\c field_tata_truth;

-- Truth records table with integrity validation
CREATE TABLE IF NOT EXISTS truth_records (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    data_hash VARCHAR(64) NOT NULL UNIQUE,
    content JSONB NOT NULL,
    frequency INTEGER DEFAULT 432,
    verified BOOLEAN DEFAULT FALSE,
    verification_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_truth_timestamp ON truth_records(timestamp);
CREATE INDEX idx_truth_hash ON truth_records(data_hash);
CREATE INDEX idx_truth_verified ON truth_records(verified);
CREATE INDEX idx_truth_content ON truth_records USING GIN(content);

-- Audit log table
CREATE TABLE IF NOT EXISTS truth_audit_log (
    id SERIAL PRIMARY KEY,
    record_id INTEGER REFERENCES truth_records(id),
    action VARCHAR(50) NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB
);

-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for automatic timestamp updates
CREATE TRIGGER truth_records_updated_at
    BEFORE UPDATE ON truth_records
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Create user for TATA service
CREATE USER field_tata WITH PASSWORD 'change_me_in_production';
GRANT ALL PRIVILEGES ON DATABASE field_tata_truth TO field_tata;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO field_tata;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO field_tata;

-- Verify installation
SELECT 'TATA Foundation Database (432Hz) initialized successfully' AS status;

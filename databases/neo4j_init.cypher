// ● OBI-WAN Memory Graph (639Hz)
// Neo4j Initialization Script

// Create constraints for unique identifiers
CREATE CONSTRAINT memory_id IF NOT EXISTS FOR (m:Memory) REQUIRE m.id IS UNIQUE;
CREATE CONSTRAINT observation_id IF NOT EXISTS FOR (o:Observation) REQUIRE o.id IS UNIQUE;
CREATE CONSTRAINT pattern_id IF NOT EXISTS FOR (p:Pattern) REQUIRE p.id IS UNIQUE;

// Create indexes for performance
CREATE INDEX memory_timestamp IF NOT EXISTS FOR (m:Memory) ON (m.timestamp);
CREATE INDEX memory_frequency IF NOT EXISTS FOR (m:Memory) ON (m.frequency);
CREATE INDEX observation_type IF NOT EXISTS FOR (o:Observation) ON (o.type);
CREATE INDEX observation_timestamp IF NOT EXISTS FOR (o:Observation) ON (o.timestamp);
CREATE INDEX pattern_name IF NOT EXISTS FOR (p:Pattern) ON (p.name);

// Create sample memory structure
CREATE (root:Memory {
    id: 'root-639',
    name: 'OBI-WAN Root Memory',
    frequency: 639,
    timestamp: datetime(),
    type: 'root'
});

// Create relationship types
// OBSERVES - links observations to memories
// RELATES_TO - links related memories
// PART_OF - links memories to patterns
// EVOLVES_FROM - tracks memory evolution

RETURN 'OBI-WAN Memory Graph (639Hz) initialized successfully' AS status;

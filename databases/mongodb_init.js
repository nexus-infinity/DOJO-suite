// ▲ ATLAS Intelligence Database (528Hz)
// MongoDB Initialization Script

use field_atlas;

// Design registry collection
db.createCollection("designs", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["name", "frequency", "created_at"],
            properties: {
                name: {
                    bsonType: "string",
                    description: "Design name - required"
                },
                frequency: {
                    bsonType: "int",
                    description: "Frequency (Hz) - required"
                },
                design_data: {
                    bsonType: "object",
                    description: "Design payload"
                },
                tags: {
                    bsonType: "array",
                    items: {
                        bsonType: "string"
                    }
                },
                created_at: {
                    bsonType: "date",
                    description: "Creation timestamp - required"
                },
                updated_at: {
                    bsonType: "date"
                }
            }
        }
    }
});

// Intelligence history collection
db.createCollection("intelligence_history", {
    validator: {
        $jsonSchema: {
            bsonType: "object",
            required: ["event_type", "timestamp"],
            properties: {
                event_type: {
                    bsonType: "string",
                    description: "Type of intelligence event"
                },
                data: {
                    bsonType: "object"
                },
                timestamp: {
                    bsonType: "date"
                },
                frequency: {
                    bsonType: "int"
                }
            }
        }
    }
});

// Create indexes
db.designs.createIndex({ "name": 1 });
db.designs.createIndex({ "created_at": -1 });
db.designs.createIndex({ "frequency": 1 });
db.designs.createIndex({ "tags": 1 });

db.intelligence_history.createIndex({ "timestamp": -1 });
db.intelligence_history.createIndex({ "event_type": 1 });

// Create user for ATLAS service
db.createUser({
    user: "atlas_intelligence",
    pwd: "change_me_in_production",
    roles: [
        { role: "readWrite", db: "field_atlas" }
    ]
});

print("ATLAS Intelligence Database (528Hz) initialized successfully");

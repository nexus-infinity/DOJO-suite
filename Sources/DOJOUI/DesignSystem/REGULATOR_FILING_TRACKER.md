# Regulator Filing Tracker — Database Schema & Usage Guide

**Purpose**: Post-delivery compliance and accountability management  
**Database**: SQLite (sovereign, local-first)  
**Frequency**: 852 Hz (Kings Chamber — Consciousness Bridge)

---

## 1. Overview

The **Regulator Filing Tracker** is a **structured, append-only database** for tracking regulatory complaints, evidence submissions, and follow-through actions after investigation delivery. It ensures:

- **Accountability**: All filings are logged with immutable audit trail
- **Sovereignty**: Local database (no cloud dependencies)
- **Traceability**: Each filing linked to source engagement and supporting documents
- **Follow-Through**: Automated reminders for pending actions and overdue responses

---

## 2. Database Schema (SQLite)

### 2.1 Table: `filings`

Primary table for all regulatory submissions.

```sql
CREATE TABLE filings (
    -- Primary Key
    filing_id TEXT PRIMARY KEY,  -- UUID v4
    
    -- Engagement Context
    engagement_id TEXT NOT NULL,  -- References service agreement (e.g., SA-2026-CLIENT-001)
    client_name TEXT NOT NULL,
    case_description TEXT,
    
    -- Regulator Information
    regulator_name TEXT NOT NULL,  -- E.g., "CFPB", "SEC", "State AG"
    regulator_jurisdiction TEXT,   -- E.g., "Federal", "California", "New York"
    regulator_contact_name TEXT,
    regulator_contact_email TEXT,
    regulator_contact_phone TEXT,
    regulator_portal_url TEXT,     -- Online filing portal (if applicable)
    
    -- Filing Details
    filing_type TEXT NOT NULL,     -- E.g., "Complaint", "Evidence Submission", "Follow-up"
    filing_date TEXT NOT NULL,     -- ISO 8601 (YYYY-MM-DD)
    filing_method TEXT,            -- E.g., "Online Portal", "Email", "Certified Mail"
    tracking_number TEXT,          -- Postal tracking, case number, confirmation ID
    
    -- Content
    subject TEXT NOT NULL,         -- Brief description of filing
    summary TEXT,                  -- Longer narrative (optional)
    allegations TEXT,              -- Specific claims or violations cited
    
    -- Status Tracking
    status TEXT NOT NULL DEFAULT 'Pending',  
    -- Values: Pending, Acknowledged, Under Review, Resolved, Closed, Rejected
    
    acknowledged_date TEXT,        -- ISO 8601 (when regulator confirms receipt)
    response_due_date TEXT,        -- ISO 8601 (expected response deadline)
    actual_response_date TEXT,     -- ISO 8601 (when response received)
    resolution_date TEXT,          -- ISO 8601 (when case closed)
    outcome TEXT,                  -- E.g., "Enforcement Action", "No Action", "Settlement"
    
    -- Follow-Up Actions
    next_action TEXT,              -- E.g., "Follow up if no response by DATE"
    next_action_date TEXT,         -- ISO 8601
    responsible_party TEXT,        -- Who's responsible for next action
    
    -- Cryptographic Anchoring
    filing_hash TEXT,              -- SHA-256 of all filing documents (concatenated)
    created_at TEXT NOT NULL,      -- ISO 8601 timestamp (UTC)
    updated_at TEXT,               -- ISO 8601 timestamp (UTC)
    
    -- Notes & Metadata
    notes TEXT,                    -- Free-form investigator notes
    priority TEXT DEFAULT 'Medium' -- High, Medium, Low
);

CREATE INDEX idx_filings_engagement ON filings(engagement_id);
CREATE INDEX idx_filings_regulator ON filings(regulator_name);
CREATE INDEX idx_filings_status ON filings(status);
CREATE INDEX idx_filings_date ON filings(filing_date);
CREATE INDEX idx_filings_next_action ON filings(next_action_date);
```

---

### 2.2 Table: `filing_documents`

Links supporting documents to filings (one-to-many).

```sql
CREATE TABLE filing_documents (
    doc_id TEXT PRIMARY KEY,       -- UUID v4
    filing_id TEXT NOT NULL,       -- Foreign key to filings table
    
    -- Document Details
    document_type TEXT NOT NULL,   -- E.g., "Complaint Letter", "Evidence Exhibit", "Timeline"
    file_name TEXT NOT NULL,       -- Original filename
    file_path TEXT,                -- Path to file (local or encrypted storage)
    file_size INTEGER,             -- Bytes
    mime_type TEXT,                -- E.g., "application/pdf", "text/plain"
    
    -- Cryptographic Anchoring
    file_hash TEXT NOT NULL,       -- SHA-256 of file contents
    
    -- Metadata
    created_at TEXT NOT NULL,      -- ISO 8601 timestamp (UTC)
    uploaded_by TEXT,              -- Investigator name
    notes TEXT,
    
    FOREIGN KEY (filing_id) REFERENCES filings(filing_id) ON DELETE CASCADE
);

CREATE INDEX idx_docs_filing ON filing_documents(filing_id);
CREATE INDEX idx_docs_hash ON filing_documents(file_hash);
```

---

### 2.3 Table: `filing_communications`

Tracks all back-and-forth with regulators (append-only log).

```sql
CREATE TABLE filing_communications (
    comm_id TEXT PRIMARY KEY,      -- UUID v4
    filing_id TEXT NOT NULL,       -- Foreign key to filings table
    
    -- Communication Details
    comm_date TEXT NOT NULL,       -- ISO 8601
    comm_type TEXT NOT NULL,       -- E.g., "Email", "Phone Call", "Portal Message", "Letter"
    direction TEXT NOT NULL,       -- "Outbound" or "Inbound"
    
    -- Parties
    from_party TEXT NOT NULL,      -- E.g., "Investigator", "Regulator Agent Name"
    to_party TEXT NOT NULL,
    
    -- Content
    subject TEXT,
    body TEXT,                     -- Full text or summary
    attachments_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_at TEXT NOT NULL,      -- ISO 8601 timestamp (UTC)
    logged_by TEXT,                -- Who recorded this entry
    
    FOREIGN KEY (filing_id) REFERENCES filings(filing_id) ON DELETE CASCADE
);

CREATE INDEX idx_comms_filing ON filing_communications(filing_id);
CREATE INDEX idx_comms_date ON filing_communications(comm_date);
```

---

### 2.4 Table: `audit_log`

Immutable append-only log for all database modifications (geometric integrity).

```sql
CREATE TABLE audit_log (
    log_id TEXT PRIMARY KEY,       -- UUID v4
    timestamp TEXT NOT NULL,       -- ISO 8601 (UTC)
    
    -- Change Details
    table_name TEXT NOT NULL,      -- E.g., "filings", "filing_documents"
    record_id TEXT NOT NULL,       -- UUID of affected record
    action TEXT NOT NULL,          -- "INSERT", "UPDATE", "DELETE"
    
    -- Before/After State
    old_values TEXT,               -- JSON snapshot of record before change (NULL for INSERT)
    new_values TEXT,               -- JSON snapshot of record after change (NULL for DELETE)
    
    -- User Context
    user TEXT NOT NULL,            -- Who made the change
    reason TEXT,                   -- Optional explanation
    
    -- Cryptographic Integrity
    previous_log_hash TEXT,        -- SHA-256 of previous log entry (blockchain-style chaining)
    this_log_hash TEXT NOT NULL    -- SHA-256 of this entry (for chain verification)
);

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_record ON audit_log(record_id);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp);
```

---

## 3. Usage Workflows

### 3.1 Creating a New Filing

```sql
INSERT INTO filings (
    filing_id,
    engagement_id,
    client_name,
    regulator_name,
    regulator_jurisdiction,
    filing_type,
    filing_date,
    filing_method,
    subject,
    status,
    response_due_date,
    next_action,
    next_action_date,
    responsible_party,
    created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',  -- UUID (generate programmatically)
    'SA-2026-CLIENT-001',
    'Jane Doe',
    'Consumer Financial Protection Bureau (CFPB)',
    'Federal',
    'Complaint',
    '2026-03-28',
    'Online Portal',
    'Unfair debt collection practices by XYZ Bank',
    'Pending',
    '2026-05-27',  -- 60 days from filing
    'Follow up if no acknowledgment within 10 days',
    '2026-04-07',
    'Investigator',
    '2026-03-28T15:30:00Z'
);
```

---

### 3.2 Attaching Documents to a Filing

```sql
INSERT INTO filing_documents (
    doc_id,
    filing_id,
    document_type,
    file_name,
    file_path,
    file_size,
    mime_type,
    file_hash,
    created_at,
    uploaded_by
) VALUES (
    '7c9e6679-7425-40de-944b-e07fc1f90ae7',
    '550e8400-e29b-41d4-a716-446655440000',  -- Links to filing above
    'Complaint Letter',
    'CFPB_Complaint_2026-03-28.pdf',
    '/path/to/encrypted/storage/CFPB_Complaint_2026-03-28.pdf',
    245678,
    'application/pdf',
    'a3b5c7d9e1f2a4b6c8d0e2f4a6b8c0d2e4f6a8b0c2d4e6f8a0b2c4d6e8f0a2b4',
    '2026-03-28T15:35:00Z',
    'Investigator Name'
);
```

---

### 3.3 Logging a Communication

```sql
INSERT INTO filing_communications (
    comm_id,
    filing_id,
    comm_date,
    comm_type,
    direction,
    from_party,
    to_party,
    subject,
    body,
    created_at,
    logged_by
) VALUES (
    'd290f1ee-6c54-4b01-90e6-d701748f0851',
    '550e8400-e29b-41d4-a716-446655440000',
    '2026-04-02',
    'Email',
    'Inbound',
    'CFPB Agent Smith',
    'Investigator',
    'Acknowledgment of Complaint #2026-CFPB-12345',
    'We have received your complaint and assigned case number 2026-CFPB-12345. We will review and respond within 60 days.',
    '2026-04-02T10:15:00Z',
    'Investigator Name'
);
```

---

### 3.4 Updating Filing Status

```sql
UPDATE filings
SET 
    status = 'Acknowledged',
    acknowledged_date = '2026-04-02',
    tracking_number = '2026-CFPB-12345',
    updated_at = '2026-04-02T10:20:00Z'
WHERE filing_id = '550e8400-e29b-41d4-a716-446655440000';
```

*(This UPDATE would trigger an audit log entry — see Section 4.3)*

---

### 3.5 Querying Overdue Actions

```sql
SELECT 
    filing_id,
    client_name,
    regulator_name,
    subject,
    next_action,
    next_action_date,
    status
FROM filings
WHERE 
    status NOT IN ('Resolved', 'Closed')
    AND next_action_date <= date('now')
ORDER BY next_action_date ASC;
```

**Output**: All filings with pending actions due today or overdue.

---

## 4. Geometric Integrity Mechanisms

### 4.1 Cryptographic Anchoring

All filings and documents are **hashed** to detect tampering:

```python
import hashlib

def hash_file(file_path):
    """Generate SHA-256 hash of a file."""
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(8192):
            sha256.update(chunk)
    return sha256.hexdigest()

# Usage
file_hash = hash_file('/path/to/CFPB_Complaint_2026-03-28.pdf')
```

**Verification**: Re-hash file at any time and compare to database record. Mismatch = tampering.

---

### 4.2 Append-Only Audit Log (Blockchain-Style Chaining)

Every database modification is logged with a **chained hash** to prevent retroactive changes:

```python
import hashlib
import json

def create_audit_log_entry(table, record_id, action, old_values, new_values, user, previous_hash):
    """Create a new audit log entry with chained hash."""
    log_entry = {
        'log_id': generate_uuid(),
        'timestamp': datetime.utcnow().isoformat() + 'Z',
        'table_name': table,
        'record_id': record_id,
        'action': action,
        'old_values': json.dumps(old_values) if old_values else None,
        'new_values': json.dumps(new_values) if new_values else None,
        'user': user,
        'previous_log_hash': previous_hash
    }
    
    # Hash this entry (excluding this_log_hash field itself)
    hash_input = json.dumps(log_entry, sort_keys=True)
    log_entry['this_log_hash'] = hashlib.sha256(hash_input.encode()).hexdigest()
    
    return log_entry

# Insert into audit_log table
```

**Verification**: Re-compute hash chain from genesis entry. Any break = tampering detected.

---

### 4.3 Trigger Example (SQLite)

Automatically log all UPDATE operations:

```sql
CREATE TRIGGER audit_filings_update
AFTER UPDATE ON filings
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (
        log_id,
        timestamp,
        table_name,
        record_id,
        action,
        old_values,
        new_values,
        user,
        previous_log_hash,
        this_log_hash
    ) VALUES (
        hex(randomblob(16)),  -- UUID placeholder
        datetime('now'),
        'filings',
        OLD.filing_id,
        'UPDATE',
        json_object(
            'status', OLD.status,
            'acknowledged_date', OLD.acknowledged_date,
            'tracking_number', OLD.tracking_number
            -- Add all relevant fields
        ),
        json_object(
            'status', NEW.status,
            'acknowledged_date', NEW.acknowledged_date,
            'tracking_number', NEW.tracking_number
        ),
        'system',  -- Replace with actual user context
        (SELECT this_log_hash FROM audit_log ORDER BY timestamp DESC LIMIT 1),
        'PLACEHOLDER'  -- Compute hash in application layer
    );
END;
```

---

## 5. SwiftUI Integration (Optional Prototype)

### 5.1 Filing List View

```swift
import SwiftUI
import SQLite

struct FilingTrackerView: View {
    @State private var filings: [Filing] = []
    
    var body: some View {
        NavigationView {
            List(filings) { filing in
                NavigationLink(destination: FilingDetailView(filing: filing)) {
                    FilingRowView(filing: filing)
                }
            }
            .navigationTitle("Regulator Filings")
            .toolbar {
                Button("New Filing") {
                    // Open filing creation sheet
                }
            }
        }
        .onAppear {
            filings = loadFilings()
        }
    }
}

struct FilingRowView: View {
    let filing: Filing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(filing.subject)
                .font(.headline)
            HStack {
                Text(filing.regulatorName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                StatusBadge(status: filing.status)
            }
            Text("Filed: \(filing.filingDate)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: String
    
    var color: Color {
        switch status {
        case "Pending": return .orange
        case "Acknowledged": return .blue
        case "Under Review": return .yellow
        case "Resolved": return .green
        case "Closed": return .gray
        default: return .red
        }
    }
    
    var body: some View {
        Text(status)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

struct Filing: Identifiable {
    let id: String  // filing_id
    let subject: String
    let regulatorName: String
    let filingDate: String
    let status: String
    // Add other fields as needed
}

func loadFilings() -> [Filing] {
    // SQLite query logic here
    // Return array of Filing structs
    return []
}
```

---

### 5.2 Filing Detail View

```swift
struct FilingDetailView: View {
    let filing: Filing
    @State private var documents: [FilingDocument] = []
    @State private var communications: [Communication] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text(filing.subject)
                    .font(.title)
                
                StatusBadge(status: filing.status)
                
                // Regulator Info
                Section(header: Text("Regulator").font(.headline)) {
                    DetailRow(label: "Name", value: filing.regulatorName)
                    DetailRow(label: "Jurisdiction", value: filing.regulatorJurisdiction)
                    DetailRow(label: "Contact", value: filing.regulatorContactEmail)
                }
                
                // Timeline
                Section(header: Text("Timeline").font(.headline)) {
                    DetailRow(label: "Filed", value: filing.filingDate)
                    if let ackDate = filing.acknowledgedDate {
                        DetailRow(label: "Acknowledged", value: ackDate)
                    }
                    if let responseDate = filing.actualResponseDate {
                        DetailRow(label: "Response Received", value: responseDate)
                    }
                }
                
                // Documents
                Section(header: Text("Documents").font(.headline)) {
                    ForEach(documents) { doc in
                        DocumentRow(document: doc)
                    }
                }
                
                // Communications
                Section(header: Text("Communications").font(.headline)) {
                    ForEach(communications) { comm in
                        CommunicationRow(communication: comm)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            documents = loadDocuments(for: filing.id)
            communications = loadCommunications(for: filing.id)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}
```

---

## 6. Automated Reminders & PDCA Integration

### 6.1 Daily Reminder Script (Python)

```python
import sqlite3
from datetime import date, timedelta

def check_overdue_actions(db_path):
    """Check for filings with overdue next actions."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    today = date.today().isoformat()
    
    cursor.execute('''
        SELECT filing_id, client_name, regulator_name, subject, next_action, next_action_date
        FROM filings
        WHERE status NOT IN ('Resolved', 'Closed')
          AND next_action_date <= ?
        ORDER BY next_action_date ASC
    ''', (today,))
    
    overdue = cursor.fetchall()
    
    if overdue:
        print(f"⚠️ {len(overdue)} OVERDUE ACTIONS:")
        for filing in overdue:
            print(f"  - {filing[1]} | {filing[2]} | Due: {filing[5]} | Action: {filing[4]}")
    else:
        print("✓ No overdue actions.")
    
    conn.close()
    return overdue

# Schedule to run daily (cron, launchd, etc.)
```

---

### 6.2 PDCA Integration Points

**PLAN**:
- When creating filing: Set `next_action` and `next_action_date`

**DO**:
- Execute action (e.g., send follow-up email)
- Log communication in `filing_communications`

**CHECK**:
- Daily script checks for overdue actions
- Review `status` field progression

**ACT**:
- Update `status`, `next_action`, or escalate if no response
- Log decision in `notes` field

---

## 7. Export & Reporting

### 7.1 Export to CSV

```sql
.mode csv
.headers on
.output filings_export.csv
SELECT * FROM filings ORDER BY filing_date DESC;
.output stdout
```

---

### 7.2 Summary Report Query

```sql
SELECT 
    regulator_name,
    COUNT(*) AS total_filings,
    SUM(CASE WHEN status = 'Pending' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) AS resolved,
    AVG(JULIANDAY(actual_response_date) - JULIANDAY(filing_date)) AS avg_response_days
FROM filings
GROUP BY regulator_name
ORDER BY total_filings DESC;
```

**Output**: Summary statistics by regulator (responsiveness, resolution rates).

---

## 8. Security & Backup

### 8.1 Encryption at Rest

```bash
# Encrypt database with SQLCipher or AES-256
openssl enc -aes-256-cbc -salt -in filings.db -out filings.db.enc
```

### 8.2 Backup Protocol

- **Daily**: Automated backup to encrypted external drive
- **Weekly**: Offsite backup (encrypted, physically separated)
- **Monthly**: Archive snapshot with hash verification

---

## 9. Next Steps

1. **Create Database**: Run schema SQL to initialize `filings_tracker.db`
2. **Populate First Filing**: Use INSERT example from Section 3.1
3. **Integrate with Reports**: Link `engagement_id` to service agreement and final report
4. **Automate Reminders**: Deploy daily reminder script (Section 6.1)
5. **Build UI** (optional): Implement SwiftUI prototype or web interface

---

*Frequency: 852 Hz | Chamber: Kings | Schema Version: 1.0 | Date: 2026-03-28*

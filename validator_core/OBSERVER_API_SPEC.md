# Observer Interface API Specification

## Core Endpoints

### 1. Flow Control

#### Pause Flow
```typescript
POST /api/observer/flow/pause
Body: {
  timestamp: string;  // ISO format
  comment?: string;
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    state: "paused" | "active" | "error";
    coherence_state: string;
    current_domain: string;
    active_gates: string[];
  };
  timestamp: string;
  trace_id?: string;
}
```

#### Resume Flow
```typescript
POST /api/observer/flow/resume
Body: {
  timestamp: string;
  comment?: string;
  trace_id?: string;
}
Response: {
  // Same as pause response
}
```

#### Advance Flow
```typescript
POST /api/observer/flow/advance
Body: {
  step_type: "prime_sequence" | "field_address" | "gate_transition";
  params: {
    // For prime_sequence
    sequence?: number[];
    
    // For field_address
    latitude?: string;
    longitude?: string;
    temporal?: string;
    
    // For gate_transition
    gate?: string;
    from_domain?: string;
    to_domain?: string;
  };
  timestamp: string;
  comment?: string;
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    // Flow state details
  };
  timestamp: string;
  trace_id?: string;
}
```

### 2. State Management

#### Quarantine Flow
```typescript
POST /api/observer/flow/quarantine
Body: {
  reason: string;
  timestamp: string;
  comment?: string;
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    state: "quarantined";
    reason: string;
    // Additional state details
  };
  timestamp: string;
  trace_id?: string;
}
```

#### Override Validation
```typescript
POST /api/observer/validation/override
Body: {
  type: string;  // Validation type to override
  value: any;    // Override value
  comment: string; // Required for override
  timestamp: string;
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    active_overrides: {
      [key: string]: {
        value: any;
        comment: string;
        timestamp: string;
      };
    };
  };
  timestamp: string;
  trace_id?: string;
}
```

### 3. Inspection

#### Inspect State
```typescript
GET /api/observer/state/inspect
Query: {
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    flow_state: string;
    coherence_state: string;
    current_domain: string;
    active_gates: string[];
    field_coordinates: {
      latitude: string;
      longitude: string;
      temporal: string;
    };
    prime_sequence: number[];
    active_overrides: object;
  };
  timestamp: string;
  trace_id?: string;
}
```

#### Trace History
```typescript
GET /api/observer/state/trace
Query: {
  limit?: number;  // Default: 10
  trace_id?: string;
}
Response: {
  success: boolean;
  message: string;
  state: {
    history: Array<{
      timestamp: string;
      event_type: string;
      result: object;
      flow_state: string;
    }>;
  };
  timestamp: string;
  trace_id?: string;
}
```

## WebSocket Events

### Observer Notifications
```typescript
interface ObserverNotification {
  type: "state_change" | "validation_result" | "coherence_alert";
  payload: {
    timestamp: string;
    state?: object;
    message?: string;
    alert_level?: string;
  };
  trace_id?: string;
}
```

### Real-time State Updates
```typescript
interface StateUpdate {
  type: "flow_state" | "coherence_state" | "validation_state";
  payload: {
    previous_state: object;
    current_state: object;
    timestamp: string;
  };
  trace_id?: string;
}
```

## Integration Points

### Front-end Components

1. **Observer Control Panel**:
```typescript
interface ObserverControlProps {
  onPause: () => Promise<void>;
  onResume: () => Promise<void>;
  onAdvance: (params: AdvanceParams) => Promise<void>;
  onQuarantine: (reason: string) => Promise<void>;
  onOverride: (params: OverrideParams) => Promise<void>;
}
```

2. **State Visualization**:
```typescript
interface StateVisualizerProps {
  flowState: FlowState;
  coherenceState: CoherenceState;
  activeGates: string[];
  coordinates: FieldCoordinates;
  onInspect: () => Promise<void>;
  onTrace: (limit: number) => Promise<void>;
}
```

3. **Validation History**:
```typescript
interface ValidationHistoryProps {
  history: ValidationEvent[];
  onTraceRequest: (params: TraceParams) => Promise<void>;
  onHistoryInspect: (event: ValidationEvent) => void;
}
```

### Connection Points

1. **FIELD Home Integration**:
```typescript
const FIELD_ANCHOR_POINT = "/FIELD/●_DOJO/validator_core";
const OBSERVER_ENDPOINT = `${FIELD_ANCHOR_POINT}/observer`;
```

2. **WebSocket Connection**:
```typescript
const OBSERVER_SOCKET = new WebSocket(
  `ws://${FIELD_ANCHOR_POINT}/observer/ws`
);
```

3. **State Synchronization**:
```typescript
interface StateSyncConfig {
  syncInterval: number;  // ms
  retryAttempts: number;
  errorHandler: (error: Error) => void;
  onStateChange: (newState: FlowState) => void;
}
```

## Usage Example

```typescript
// Initialize Observer connection
const observer = new ObserverInterface({
  endpoint: OBSERVER_ENDPOINT,
  socket: OBSERVER_SOCKET,
  onStateChange: (state) => {
    // Update UI
  },
  onError: (error) => {
    // Handle error
  }
});

// Execute Observer command
await observer.executeCommand({
  action: ObserverAction.PAUSE,
  parameters: {},
  timestamp: new Date().toISOString(),
  comment: "Manual pause by Observer"
});
```

This specification provides all necessary hooks for the Vercel front-end to integrate with the Observer system. Once you determine the appropriate location in the home field, we can adjust the anchor points and connection details accordingly.


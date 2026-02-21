#!/usr/bin/env python3

import yaml
import logging
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from .validator import FieldValidator
from .coherence_check import CrossValidatorCoherence, CoherenceResult

class ValidationFlowState(Enum):
    INITIALIZING = "initializing"
    ACTIVE = "active"
    VALIDATING = "validating"
    TRANSITIONING = "transitioning"
    QUARANTINED = "quarantined"
    ERROR = "error"

@dataclass
class ValidationFlowContext:
    state: ValidationFlowState
    prime_sequence: List[int]
    field_coordinates: Dict[str, str]
    active_gates: List[str]
    current_domain: str
    validation_history: List[Dict[str, Any]]
    coherence_state: str
    timestamp: str

class ValidationFlowPipeline:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.validator = FieldValidator(config_path)
        self.coherence_checker = CrossValidatorCoherence()
        self.flow_context = ValidationFlowContext(
            state=ValidationFlowState.INITIALIZING,
            prime_sequence=[],
            field_coordinates={},
            active_gates=[],
            current_domain="",
            validation_history=[],
            coherence_state="coherent",
            timestamp=datetime.utcnow().isoformat() + 'Z'
        )
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger("ValidationFlowPipeline")

    def initialize_flow(self, initial_context: Dict[str, Any]) -> bool:
        """Initializes the validation flow pipeline."""
        try:
            self.flow_context.prime_sequence = initial_context.get('prime_sequence', [])
            self.flow_context.field_coordinates = initial_context.get('coordinates', {})
            self.flow_context.current_domain = initial_context.get('domain', '')
            
            # Validate initial state
            if not self._validate_initial_state():
                return False

            self.flow_context.state = ValidationFlowState.ACTIVE
            self._notify_observer("Flow initialized successfully")
            return True

        except Exception as e:
            self.logger.error(f"Flow initialization error: {str(e)}")
            self.flow_context.state = ValidationFlowState.ERROR
            return False

    def process_validation_step(self, step_type: str, params: Dict[str, Any]) -> bool:
        """Processes a single validation step in the flow."""
        try:
            self.flow_context.state = ValidationFlowState.VALIDATING
            
            if step_type == "prime_sequence":
                result = self.validator.validate_prime_sequence(params['sequence'])
            elif step_type == "field_address":
                result = self.validator.validate_field_address(
                    params['latitude'],
                    params['longitude'],
                    params['temporal']
                )
            elif step_type == "gate_transition":
                result = self.validator.validate_gate_transition(
                    params['gate'],
                    params['from_domain'],
                    params['to_domain']
                )
            else:
                raise ValueError(f"Unknown validation step type: {step_type}")

            self._update_flow_state(result)
            return result.is_valid

        except Exception as e:
            self.logger.error(f"Validation step error: {str(e)}")
            self.flow_context.state = ValidationFlowState.ERROR
            return False

    def check_field_coherence(self) -> CoherenceResult:
        """Checks overall field coherence."""
        try:
            result = self.coherence_checker.check_full_field_coherence(
                self.flow_context.prime_sequence,
                self.flow_context.field_coordinates,
                self.flow_context.active_gates[-1] if self.flow_context.active_gates else "",
                self.flow_context.current_domain,
                self.flow_context.active_gates
            )

            self.flow_context.coherence_state = result.state.value
            self._update_validation_history("coherence_check", result)
            return result

        except Exception as e:
            self.logger.error(f"Coherence check error: {str(e)}")
            return self.coherence_checker._create_error_result(
                "COHERENCE_CHECK_ERROR",
                str(e)
            )

    def _validate_initial_state(self) -> bool:
        """Validates the initial flow state."""
        try:
            # Validate prime sequence
            if self.flow_context.prime_sequence:
                if not self.process_validation_step("prime_sequence", {
                    'sequence': self.flow_context.prime_sequence
                }):
                    return False

            # Validate field coordinates
            if self.flow_context.field_coordinates:
                if not self.process_validation_step("field_address", {
                    'latitude': self.flow_context.field_coordinates.get('latitude', ''),
                    'longitude': self.flow_context.field_coordinates.get('longitude', ''),
                    'temporal': self.flow_context.field_coordinates.get('temporal', '')
                }):
                    return False

            return True

        except Exception as e:
            self.logger.error(f"Initial state validation error: {str(e)}")
            return False

    def _update_flow_state(self, validation_result: Any) -> None:
        """Updates flow state based on validation result."""
        if not validation_result.is_valid:
            if validation_result.alert_level == "critical":
                self.flow_context.state = ValidationFlowState.ERROR
            elif validation_result.alert_level == "high":
                self.flow_context.state = ValidationFlowState.QUARANTINED
        else:
            self.flow_context.state = ValidationFlowState.ACTIVE

        self._update_validation_history("validation", validation_result)

    def _update_validation_history(self, event_type: str, result: Any) -> None:
        """Updates validation history with new event."""
        self.flow_context.validation_history.append({
            'timestamp': datetime.utcnow().isoformat() + 'Z',
            'event_type': event_type,
            'result': result,
            'flow_state': self.flow_context.state.value
        })

    def _notify_observer(self, message: str) -> None:
        """Notifies observer of flow state changes."""
        self.logger.info(
            f"Observer Notification: {message} | "
            f"State: {self.flow_context.state.value} | "
            f"Coherence: {self.flow_context.coherence_state}"
        )

    def get_flow_status(self) -> Dict[str, Any]:
        """Returns current flow status for observer monitoring."""
        return {
            'state': self.flow_context.state.value,
            'coherence_state': self.flow_context.coherence_state,
            'current_domain': self.flow_context.current_domain,
            'active_gates': self.flow_context.active_gates,
            'field_coordinates': self.flow_context.field_coordinates,
            'last_validation': self.flow_context.validation_history[-1] if self.flow_context.validation_history else None,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }

if __name__ == "__main__":
    # Example usage
    pipeline = ValidationFlowPipeline("validation_chain.yaml")
    
    # Initialize flow
    initial_context = {
        'domain': 'OBI-WAN',
        'prime_sequence': [2, 3, 5, 7, 11],
        'coordinates': {
            'latitude': 'FIELD/node-1/003',
            'longitude': 'OBI-WAN/personal',
            'temporal': '20250612092216Z'
        }
    }
    
    if pipeline.initialize_flow(initial_context):
        print("Flow initialized successfully")
        
        # Process validation steps
        result = pipeline.process_validation_step(
            "gate_transition",
            {
                'gate': "🜂",
                'from_domain': 'OBI-WAN',
                'to_domain': 'BERJAK'
            }
        )
        print(f"Gate transition validation: {result}")
        
        # Check field coherence
        coherence = pipeline.check_field_coherence()
        print(f"Field coherence: {coherence}")
        
        # Get flow status
        status = pipeline.get_flow_status()
        print(f"Current flow status: {status}")


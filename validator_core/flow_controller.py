#!/usr/bin/env python3

import yaml
import logging
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from .validator import FieldValidator, ValidationResult

class FlowState(Enum):
    INITIALIZING = "initializing"
    ACTIVE = "active"
    PAUSED = "paused"
    ERROR = "error"
    QUARANTINED = "quarantined"

@dataclass
class FlowContext:
    state: FlowState
    current_domain: str
    active_gates: List[str]
    prime_sequence: List[int]
    field_coordinates: Dict[str, str]
    timestamp: str
    validation_history: List[Dict[str, Any]]

class ValidationFlowController:
    def __init__(self, config_path: str):
        self.validator = FieldValidator(config_path)
        self.flow_context = FlowContext(
            state=FlowState.INITIALIZING,
            current_domain="",
            active_gates=[],
            prime_sequence=[],
            field_coordinates={},
            timestamp=datetime.utcnow().isoformat() + 'Z',
            validation_history=[]
        )
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger("ValidationFlowController")

    def begin_validation_flow(self, initial_context: Dict[str, Any]) -> ValidationResult:
        """Initiates a new validation flow with given context."""
        try:
            # Update flow context
            self.flow_context.current_domain = initial_context.get('domain', '')
            self.flow_context.prime_sequence = initial_context.get('prime_sequence', [])
            self.flow_context.field_coordinates = initial_context.get('coordinates', {})
            
            # Validate initial state
            result = self._validate_initial_state()
            if not result.is_valid:
                self.flow_context.state = FlowState.ERROR
                return result

            self.flow_context.state = FlowState.ACTIVE
            return ValidationResult(is_valid=True, timestamp=datetime.utcnow().isoformat() + 'Z')

        except Exception as e:
            self.logger.error(f"Flow initialization error: {str(e)}")
            self.flow_context.state = FlowState.ERROR
            return ValidationResult(
                is_valid=False,
                error_code="FLOW_INIT_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def process_gate_transition(self, gate: str, target_domain: str) -> ValidationResult:
        """Processes and validates a gate transition in the flow."""
        try:
            if self.flow_context.state != FlowState.ACTIVE:
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_FLOW_STATE",
                    error_message=f"Flow not active. Current state: {self.flow_context.state}",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Validate gate transition
            result = self.validator.validate_gate_transition(
                gate,
                self.flow_context.current_domain,
                target_domain
            )

            if result.is_valid:
                # Update flow context
                self.flow_context.active_gates.append(gate)
                self.flow_context.current_domain = target_domain
                self._update_validation_history(result)
            else:
                self._handle_validation_failure(result)

            return result

        except Exception as e:
            self.logger.error(f"Gate transition error: {str(e)}")
            return ValidationResult(
                is_valid=False,
                error_code="GATE_TRANSITION_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def update_field_coordinates(self, new_coordinates: Dict[str, str]) -> ValidationResult:
        """Updates and validates new field coordinates."""
        try:
            result = self.validator.validate_field_address(
                new_coordinates.get('latitude', ''),
                new_coordinates.get('longitude', ''),
                new_coordinates.get('temporal', datetime.utcnow().isoformat() + 'Z')
            )

            if result.is_valid:
                self.flow_context.field_coordinates = new_coordinates
                self._update_validation_history(result)
            else:
                self._handle_validation_failure(result)

            return result

        except Exception as e:
            self.logger.error(f"Coordinate update error: {str(e)}")
            return ValidationResult(
                is_valid=False,
                error_code="COORDINATE_UPDATE_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def _validate_initial_state(self) -> ValidationResult:
        """Validates the initial flow state."""
        # Validate prime sequence
        if self.flow_context.prime_sequence:
            result = self.validator.validate_prime_sequence(self.flow_context.prime_sequence)
            if not result.is_valid:
                return result

        # Validate field coordinates if present
        if self.flow_context.field_coordinates:
            result = self.validator.validate_field_address(
                self.flow_context.field_coordinates.get('latitude', ''),
                self.flow_context.field_coordinates.get('longitude', ''),
                self.flow_context.field_coordinates.get('temporal', '')
            )
            if not result.is_valid:
                return result

        return ValidationResult(is_valid=True, timestamp=datetime.utcnow().isoformat() + 'Z')

    def _handle_validation_failure(self, result: ValidationResult) -> None:
        """Handles validation failures based on severity."""
        if result.alert_level == "critical":
            self.flow_context.state = FlowState.ERROR
        elif result.alert_level == "high":
            self.flow_context.state = FlowState.QUARANTINED
        
        self._update_validation_history(result)
        self._notify_observer(result)

    def _update_validation_history(self, result: ValidationResult) -> None:
        """Updates the validation history with new result."""
        self.flow_context.validation_history.append({
            'timestamp': result.timestamp,
            'result': result,
            'flow_state': self.flow_context.state.value
        })

    def _notify_observer(self, result: ValidationResult) -> None:
        """Notifies observer of validation state changes."""
        self.logger.info(
            f"Observer Notification: Flow State: {self.flow_context.state.value}, "
            f"Alert: {result.error_code} - {result.error_message}"
        )

    def get_flow_status(self) -> Dict[str, Any]:
        """Returns current flow status for observer monitoring."""
        return {
            'state': self.flow_context.state.value,
            'current_domain': self.flow_context.current_domain,
            'active_gates': self.flow_context.active_gates,
            'field_coordinates': self.flow_context.field_coordinates,
            'last_validation': self.flow_context.validation_history[-1] if self.flow_context.validation_history else None,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }

if __name__ == "__main__":
    # Example usage
    controller = ValidationFlowController("validator_config.yaml")
    
    # Initialize flow
    initial_context = {
        'domain': 'OBI-WAN',
        'prime_sequence': [2, 3, 5, 7, 11],
        'coordinates': {
            'latitude': 'FIELD/node-1/001',
            'longitude': 'OBI-WAN/personal',
            'temporal': '20250612091630Z'
        }
    }
    
    result = controller.begin_validation_flow(initial_context)
    print(f"Flow Initialization: {result}")
    
    # Process gate transition
    result = controller.process_gate_transition("🜂", "BERJAK")
    print(f"Gate Transition: {result}")
    
    # Get flow status
    status = controller.get_flow_status()
    print(f"Current Flow Status: {status}")


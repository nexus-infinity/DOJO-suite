#!/usr/bin/env python3

import yaml
import logging
from dataclasses import dataclass
from typing import List, Dict, Any, Optional
from datetime import datetime

@dataclass
class ValidationResult:
    is_valid: bool
    error_code: str = ""
    error_message: str = ""
    alert_level: str = "normal"
    timestamp: str = ""
    details: Dict[str, Any] = None

class FieldValidator:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.validation_state = {
            "last_valid_state": None,
            "current_prime_sequence": [],
            "active_gates": [],
            "field_coordinates": None
        }
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger("FieldValidator")

    def validate_prime_sequence(self, sequence: List[int]) -> ValidationResult:
        """Validates prime number sequence and progression."""
        try:
            # Check if sequence is strictly increasing
            if not all(sequence[i] < sequence[i+1] for i in range(len(sequence)-1)):
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_PRIME_PROGRESSION",
                    error_message="Prime sequence is not strictly increasing",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Verify each number is prime
            for num in sequence:
                if not self._is_prime(num):
                    return ValidationResult(
                        is_valid=False,
                        error_code="NON_PRIME_DETECTED",
                        error_message=f"Non-prime number {num} detected in sequence",
                        alert_level="critical",
                        timestamp=datetime.utcnow().isoformat() + 'Z'
                    )

            return ValidationResult(
                is_valid=True,
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

        except Exception as e:
            self.logger.error(f"Prime sequence validation error: {str(e)}")
            return ValidationResult(
                is_valid=False,
                error_code="VALIDATION_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def validate_field_address(self, latitude: str, longitude: str, temporal: str) -> ValidationResult:
        """Validates spatiotemporal field address."""
        try:
            # Validate latitude (field coordinate)
            lat_pattern = self.config['field_address_validator']['validation_rules']['latitude']['pattern']
            if not self._matches_pattern(latitude, lat_pattern):
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_FIELD_COORDINATE",
                    error_message=f"Invalid field coordinate: {latitude}",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Validate longitude (domain alignment)
            long_pattern = self.config['field_address_validator']['validation_rules']['longitude']['pattern']
            if not self._matches_pattern(longitude, long_pattern):
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_DOMAIN_ALIGNMENT",
                    error_message=f"Invalid domain alignment: {longitude}",
                    alert_level="high",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Validate temporal marker
            temp_pattern = self.config['field_address_validator']['validation_rules']['temporal']['pattern']
            if not self._matches_pattern(temporal, temp_pattern):
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_TEMPORAL_MARKER",
                    error_message=f"Invalid temporal marker: {temporal}",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            return ValidationResult(
                is_valid=True,
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

        except Exception as e:
            self.logger.error(f"Field address validation error: {str(e)}")
            return ValidationResult(
                is_valid=False,
                error_code="VALIDATION_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def validate_gate_transition(self, gate: str, from_domain: str, to_domain: str) -> ValidationResult:
        """Validates alchemical gate transitions."""
        try:
            gate_sequence = self.config['gate_validator']['gate_sequence']
            
            # Check if gate is valid
            if gate not in gate_sequence:
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_GATE",
                    error_message=f"Invalid gate symbol: {gate}",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Check domain compatibility
            if not self._are_domains_compatible(from_domain, to_domain):
                return ValidationResult(
                    is_valid=False,
                    error_code="INCOMPATIBLE_DOMAINS",
                    error_message=f"Incompatible domain transition: {from_domain} -> {to_domain}",
                    alert_level="high",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            # Check gate sequence integrity
            if not self._is_valid_gate_sequence(gate, self.validation_state['active_gates']):
                return ValidationResult(
                    is_valid=False,
                    error_code="INVALID_GATE_SEQUENCE",
                    error_message="Gate sequence violation detected",
                    alert_level="critical",
                    timestamp=datetime.utcnow().isoformat() + 'Z'
                )

            return ValidationResult(
                is_valid=True,
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

        except Exception as e:
            self.logger.error(f"Gate transition validation error: {str(e)}")
            return ValidationResult(
                is_valid=False,
                error_code="VALIDATION_ERROR",
                error_message=str(e),
                alert_level="critical",
                timestamp=datetime.utcnow().isoformat() + 'Z'
            )

    def _is_prime(self, n: int) -> bool:
        """Helper function to check if a number is prime."""
        if n < 2:
            return False
        for i in range(2, int(n ** 0.5) + 1):
            if n % i == 0:
                return False
        return True

    def _matches_pattern(self, value: str, pattern: str) -> bool:
        """Helper function to check if value matches regex pattern."""
        import re
        return bool(re.match(pattern, value))

    def _are_domains_compatible(self, from_domain: str, to_domain: str) -> bool:
        """Helper function to check domain compatibility."""
        valid_domains = ['OBI-WAN', 'BERJAK', 'INFINITY']
        return from_domain in valid_domains and to_domain in valid_domains

    def _is_valid_gate_sequence(self, new_gate: str, current_sequence: List[str]) -> bool:
        """Helper function to validate gate sequence integrity."""
        gate_sequence = self.config['gate_validator']['gate_sequence']
        if not current_sequence:
            return new_gate == gate_sequence[0]
        current_index = gate_sequence.index(current_sequence[-1])
        next_valid_index = (current_index + 1) % len(gate_sequence)
        return new_gate == gate_sequence[next_valid_index]

    def update_validation_state(self, result: ValidationResult) -> None:
        """Updates internal validation state and notifies observer."""
        if result.is_valid:
            self.validation_state['last_valid_state'] = {
                'timestamp': result.timestamp,
                'details': result.details
            }
        self._notify_observer(result)

    def _notify_observer(self, result: ValidationResult) -> None:
        """Notifies observer of validation results."""
        if result.alert_level in ['high', 'critical']:
            self.logger.warning(f"Observer Alert: {result.error_code} - {result.error_message}")

if __name__ == "__main__":
    # Example usage
    validator = FieldValidator("validator_config.yaml")
    
    # Test prime sequence validation
    result = validator.validate_prime_sequence([2, 3, 5, 7, 11])
    print(f"Prime Sequence Validation: {result}")
    
    # Test field address validation
    result = validator.validate_field_address(
        "FIELD/node-1/001",
        "OBI-WAN/personal",
        "20250612091427Z"
    )
    print(f"Field Address Validation: {result}")
    
    # Test gate transition validation
    result = validator.validate_gate_transition("🜂", "OBI-WAN", "BERJAK")
    print(f"Gate Transition Validation: {result}")


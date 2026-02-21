#!/usr/bin/env python3

import logging
from typing import Dict, List, Any
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from .validation_flow import ValidationFlowPipeline, ValidationFlowState

class ObserverAction(Enum):
    PAUSE = "pause"
    RESUME = "resume"
    ADVANCE = "advance"
    QUARANTINE = "quarantine"
    OVERRIDE = "override"
    INSPECT = "inspect"
    TRACE = "trace"

@dataclass
class ObserverCommand:
    action: ObserverAction
    parameters: Dict[str, Any]
    timestamp: str
    comment: str = ""
    trace_id: str = ""

@dataclass
class ObserverResponse:
    success: bool
    message: str
    state: Dict[str, Any]
    timestamp: str
    trace_id: str = ""

class ObserverInterface:
    def __init__(self, flow_controller: ValidationFlowPipeline):
        self.flow_controller = flow_controller
        self.command_history: List[ObserverCommand] = []
        self.active_overrides: Dict[str, Any] = {}
        
        logging.basicConfig(level=logging.INFO)
        self.logger = logging.getLogger("ObserverInterface")

    def execute_command(self, command: ObserverCommand) -> ObserverResponse:
        """Executes an Observer command and returns response."""
        try:
            if command.action == ObserverAction.PAUSE:
                return self._pause_flow(command)
            elif command.action == ObserverAction.RESUME:
                return self._resume_flow(command)
            elif command.action == ObserverAction.ADVANCE:
                return self._advance_flow(command)
            elif command.action == ObserverAction.QUARANTINE:
                return self._quarantine_flow(command)
            elif command.action == ObserverAction.OVERRIDE:
                return self._override_validation(command)
            elif command.action == ObserverAction.INSPECT:
                return self._inspect_state(command)
            elif command.action == ObserverAction.TRACE:
                return self._trace_history(command)
            else:
                raise ValueError(f"Unknown Observer action: {command.action}")

        except Exception as e:
            self.logger.error(f"Observer command execution error: {str(e)}")
            return ObserverResponse(
                success=False,
                message=f"Command execution error: {str(e)}",
                state=self.flow_controller.get_flow_status(),
                timestamp=datetime.utcnow().isoformat() + 'Z',
                trace_id=command.trace_id
            )

    def _pause_flow(self, command: ObserverCommand) -> ObserverResponse:
        """Pauses the validation flow."""
        if self.flow_controller.flow_context.state == ValidationFlowState.ACTIVE:
            self.flow_controller.flow_context.state = ValidationFlowState.PAUSED
            self._log_command(command, "Flow paused by Observer")
            return ObserverResponse(
                success=True,
                message="Flow paused successfully",
                state=self.flow_controller.get_flow_status(),
                timestamp=datetime.utcnow().isoformat() + 'Z',
                trace_id=command.trace_id
            )
        return ObserverResponse(
            success=False,
            message="Cannot pause flow in the current state",
            state=self.flow_controller.get_flow_status(),
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _resume_flow(self, command: ObserverCommand) -> ObserverResponse:
        """Resumes the validation flow."""
        if self.flow_controller.flow_context.state == ValidationFlowState.PAUSED:
            self.flow_controller.flow_context.state = ValidationFlowState.ACTIVE
            self._log_command(command, "Flow resumed by Observer")
            return ObserverResponse(
                success=True,
                message="Flow resumed successfully",
                state=self.flow_controller.get_flow_status(),
                timestamp=datetime.utcnow().isoformat() + 'Z',
                trace_id=command.trace_id
            )
        return ObserverResponse(
            success=False,
            message="Cannot resume flow in the current state",
            state=self.flow_controller.get_flow_status(),
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _advance_flow(self, command: ObserverCommand) -> ObserverResponse:
        """Advances the flow one step."""
        step_type = command.parameters.get('step_type')
        step_params = command.parameters.get('params', {})
        result = self.flow_controller.process_validation_step(step_type, step_params)
        self._log_command(command, f"Flow advanced: {step_type}")
        return ObserverResponse(
            success=result,
            message="Flow step processed successfully" if result else "Flow step failed",
            state=self.flow_controller.get_flow_status(),
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _quarantine_flow(self, command: ObserverCommand) -> ObserverResponse:
        """Forces flow into quarantine state."""
        self.flow_controller.flow_context.state = ValidationFlowState.QUARANTINED
        self._log_command(command, "Flow quarantined")
        return ObserverResponse(
            success=True,
            message="Flow quarantined by Observer",
            state=self.flow_controller.get_flow_status(),
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _override_validation(self, command: ObserverCommand) -> ObserverResponse:
        """Overrides validation with Observer comment."""
        override_type = command.parameters.get('type')
        override_value = command.parameters.get('value')
        self.active_overrides[override_type] = {
            'value': override_value,
            'comment': command.comment,
            'timestamp': datetime.utcnow().isoformat() + 'Z'
        }
        self._log_command(command, "Validation overridden")
        return ObserverResponse(
            success=True,
            message="Validation override applied",
            state=self.flow_controller.get_flow_status(),
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _inspect_state(self, command: ObserverCommand) -> ObserverResponse:
        """Performs a deep inspection of the current state."""
        state_inspection = self.flow_controller.get_flow_status()
        self._log_command(command, "State inspected")
        return ObserverResponse(
            success=True,
            message="State inspection complete",
            state=state_inspection,
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _trace_history(self, command: ObserverCommand) -> ObserverResponse:
        """Retrieves the validation history trace."""
        limit = command.parameters.get('limit', 10)
        history = self.flow_controller.flow_context.validation_history[-limit:]
        self._log_command(command, "History traced")
        return ObserverResponse(
            success=True,
            message="History trace complete",
            state={'history': history},
            timestamp=datetime.utcnow().isoformat() + 'Z',
            trace_id=command.trace_id
        )

    def _log_command(self, command: ObserverCommand, message: str) -> None:
        """Logs the observer command execution."""
        self.command_history.append(command)
        self.logger.info(
            f"Observer Command: {command.action.value} | "
            f"Message: {message}"
        )

if __name__ == "__main__":
    flow_controller = ValidationFlowPipeline("validation_chain.yaml")
    observer = ObserverInterface(flow_controller)
    # Example Observer commands
    commands = [
        ObserverCommand(action=ObserverAction.PAUSE, parameters={}, timestamp=datetime.utcnow().isoformat() + 'Z'),
        ObserverCommand(action=ObserverAction.RESUME, parameters={}, timestamp=datetime.utcnow().isoformat() + 'Z'),
    ]
    for cmd in commands:
        response = observer.execute_command(cmd)
        print(f"Response: {response}\n")


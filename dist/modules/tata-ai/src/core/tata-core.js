"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initialize = initialize;
exports.processInput = processInput;
var communication_1 = require("../../../shared/adapters/communication");
var dependency_injection_1 = require("../../../shared/adapters/dependency-injection");
function initialize() {
    var aiService = dependency_injection_1.DependencyInjector.getService('AIService');
    if (aiService) {
        aiService.runModel({ /* your data */});
    }
    else {
        console.error('AIService not available');
    }
}
function processInput(data) {
    communication_1.Communication.sendMessage('bear-project', data);
}

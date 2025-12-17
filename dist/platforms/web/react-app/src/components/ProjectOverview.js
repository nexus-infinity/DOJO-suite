"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var ProjectOverview = function (_a) {
    var _b = _a.projects, projects = _b === void 0 ? [] : _b;
    if (projects.length === 0) {
        return (react_1.default.createElement("div", { className: "p-4 border rounded shadow" },
            react_1.default.createElement("p", { className: "text-gray-600" }, "No projects available.")));
    }
    return (react_1.default.createElement("div", { className: "grid gap-4 md:grid-cols-2 lg:grid-cols-3" }, projects.map(function (project) { return (react_1.default.createElement("div", { key: project.id, className: "p-4 border rounded shadow" },
        react_1.default.createElement("h3", { className: "text-lg font-semibold" }, project.name),
        react_1.default.createElement("p", { className: "mt-2 text-gray-600" }, project.description))); })));
};
exports.default = ProjectOverview;

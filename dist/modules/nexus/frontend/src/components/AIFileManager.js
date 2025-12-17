'use client';
"use strict";
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AIFileManager = AIFileManager;
var react_1 = require("react");
var react_2 = require("ai/react");
var button_1 = require("@/components/ui/button");
var input_1 = require("@/components/ui/input");
var card_1 = require("@/components/ui/card");
function AIFileManager() {
    var _a = (0, react_1.useState)([]), files = _a[0], setFiles = _a[1];
    var _b = (0, react_2.useChat)(), messages = _b.messages, input = _b.input, handleInputChange = _b.handleInputChange, handleSubmit = _b.handleSubmit;
    var handleFileUpload = function (event) {
        var uploadedFiles = Array.from(event.target.files);
        setFiles(__spreadArray(__spreadArray([], files, true), uploadedFiles, true));
    };
    return (React.createElement(card_1.Card, { className: "w-full max-w-2xl" },
        React.createElement(card_1.CardContent, { className: "p-6" },
            React.createElement("div", { className: "mb-4" },
                React.createElement(input_1.Input, { type: "file", multiple: true, onChange: handleFileUpload, className: "mb-2" }),
                React.createElement("ul", { className: "list-disc pl-5" }, files.map(function (file, index) { return (React.createElement("li", { key: index, className: "text-sm text-gray-600" }, file.name)); }))),
            React.createElement("div", { className: "flex flex-col space-y-4 mb-4" }, messages.map(function (m) { return (React.createElement("div", { key: m.id, className: "p-4 rounded-lg ".concat(m.role === 'user' ? 'bg-blue-100' : 'bg-green-100') }, m.content)); })),
            React.createElement("form", { onSubmit: handleSubmit, className: "flex gap-2" },
                React.createElement(input_1.Input, { className: "flex-grow", value: input, placeholder: "Ask about your files...", onChange: handleInputChange }),
                React.createElement(button_1.Button, { type: "submit" }, "Send")))));
}

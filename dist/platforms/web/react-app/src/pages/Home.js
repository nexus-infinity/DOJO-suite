"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var Home = function () {
    return (react_1.default.createElement("div", { className: "bg-white shadow overflow-hidden sm:rounded-lg" },
        react_1.default.createElement("div", { className: "px-4 py-5 sm:px-6" },
            react_1.default.createElement("h1", { className: "text-3xl font-bold text-gray-900" }, "Welcome to Universal Framework"),
            react_1.default.createElement("p", { className: "mt-1 max-w-2xl text-sm text-gray-500" }, "A comprehensive solution for cross-platform development")),
        react_1.default.createElement("div", { className: "border-t border-gray-200" },
            react_1.default.createElement("dl", null,
                react_1.default.createElement("div", { className: "bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Description"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" }, "Universal Framework is designed to streamline development across multiple platforms, integrating AI capabilities and providing a robust set of tools and modules.")),
                react_1.default.createElement("div", { className: "bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Key Features"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" },
                        react_1.default.createElement("ul", { className: "list-disc pl-5" },
                            react_1.default.createElement("li", null, "Cross-platform compatibility"),
                            react_1.default.createElement("li", null, "Integrated AI capabilities"),
                            react_1.default.createElement("li", null, "Modular architecture"),
                            react_1.default.createElement("li", null, "Comprehensive documentation"),
                            react_1.default.createElement("li", null, "Robust testing framework"))))))));
};
exports.default = Home;

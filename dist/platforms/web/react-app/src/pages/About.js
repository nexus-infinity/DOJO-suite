"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var About = function () {
    return (react_1.default.createElement("div", { className: "bg-white shadow overflow-hidden sm:rounded-lg" },
        react_1.default.createElement("div", { className: "px-4 py-5 sm:px-6" },
            react_1.default.createElement("h1", { className: "text-3xl font-bold text-gray-900" }, "About Universal Framework"),
            react_1.default.createElement("p", { className: "mt-1 max-w-2xl text-sm text-gray-500" }, "Learn more about our project and its goals")),
        react_1.default.createElement("div", { className: "border-t border-gray-200" },
            react_1.default.createElement("dl", null,
                react_1.default.createElement("div", { className: "bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Mission"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" }, "To provide developers with a comprehensive, AI-enhanced framework for building cross-platform applications efficiently and effectively.")),
                react_1.default.createElement("div", { className: "bg-white px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Vision"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" }, "To revolutionize the development process by seamlessly integrating AI capabilities and cross-platform compatibility into a single, powerful framework.")),
                react_1.default.createElement("div", { className: "bg-gray-50 px-4 py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Core Values"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" },
                        react_1.default.createElement("ul", { className: "list-disc pl-5" },
                            react_1.default.createElement("li", null, "Innovation in development practices"),
                            react_1.default.createElement("li", null, "Commitment to open-source principles"),
                            react_1.default.createElement("li", null, "Continuous learning and improvement"),
                            react_1.default.createElement("li", null, "User-centric design and functionality"))))))));
};
exports.default = About;

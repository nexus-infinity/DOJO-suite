"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importStar(require("react"));
var Button_1 = __importDefault(require("../../../../shared/components/Button"));
var lucide_react_1 = require("lucide-react");
var App = function () {
    var _a = (0, react_1.useState)(true), sidebarOpen = _a[0], setSidebarOpen = _a[1];
    var toggleSidebar = function () {
        setSidebarOpen(!sidebarOpen);
    };
    return (react_1.default.createElement("div", { className: "flex h-screen bg-gray-100" },
        react_1.default.createElement("aside", { className: "bg-gray-800 text-white w-64 space-y-6 py-7 px-2 absolute inset-y-0 left-0 transform ".concat(sidebarOpen ? 'translate-x-0' : '-translate-x-full', " transition duration-200 ease-in-out md:relative md:translate-x-0") },
            react_1.default.createElement("nav", null,
                react_1.default.createElement("a", { href: "#", className: "block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700" }, "Dashboard"),
                react_1.default.createElement("a", { href: "#", className: "block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700" }, "Projects"),
                react_1.default.createElement("a", { href: "#", className: "block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700" }, "Tasks"),
                react_1.default.createElement("a", { href: "#", className: "block py-2.5 px-4 rounded transition duration-200 hover:bg-gray-700" }, "Calendar"))),
        react_1.default.createElement("div", { className: "flex-1 flex flex-col overflow-hidden" },
            react_1.default.createElement("header", { className: "bg-white shadow-md p-4" },
                react_1.default.createElement("div", { className: "flex items-center justify-between" },
                    react_1.default.createElement(Button_1.default, { label: sidebarOpen ? 'Close Sidebar' : 'Open Sidebar', onClick: toggleSidebar, variant: "secondary" }),
                    react_1.default.createElement("h1", { className: "text-2xl font-semibold" }, "Universal Framework Web App"),
                    react_1.default.createElement("div", { className: "flex items-center space-x-4" },
                        react_1.default.createElement(Button_1.default, { label: "", onClick: function () { return console.log('Notifications'); }, variant: "icon" },
                            react_1.default.createElement(lucide_react_1.Bell, { className: "h-5 w-5" })),
                        react_1.default.createElement(Button_1.default, { label: "", onClick: function () { return console.log('Settings'); }, variant: "icon" },
                            react_1.default.createElement(lucide_react_1.Settings, { className: "h-5 w-5" })),
                        react_1.default.createElement(Button_1.default, { label: "", onClick: function () { return console.log('Profile'); }, variant: "icon" },
                            react_1.default.createElement(lucide_react_1.User, { className: "h-5 w-5" }))))),
            react_1.default.createElement("main", { className: "flex-1 overflow-x-hidden overflow-y-auto bg-gray-200 p-6" },
                react_1.default.createElement("div", { className: "bg-white rounded-lg shadow-md p-6" },
                    react_1.default.createElement("h2", { className: "text-xl font-semibold mb-4" }, "Welcome to Your Dashboard"),
                    react_1.default.createElement("p", { className: "mb-4" }, "This is where you'll see an overview of your projects and tasks."),
                    react_1.default.createElement(Button_1.default, { label: "Create New Project", onClick: function () { return console.log('Create New Project'); }, variant: "primary" }))),
            react_1.default.createElement("footer", { className: "bg-white shadow-md p-4 mt-auto" },
                react_1.default.createElement("p", { className: "text-center text-gray-600" }, "\u00A9 2024 Universal Framework. All rights reserved.")))));
};
exports.default = App;

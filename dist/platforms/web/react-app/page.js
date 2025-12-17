"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = Home;
var link_1 = __importDefault(require("next/link"));
var button_1 = require("@/components/ui/button");
var card_1 = require("@/components/ui/card");
var lucide_react_1 = require("lucide-react");
var NewFeature_1 = __importDefault(require("@/components/NewFeature"));
var ToastDemo_1 = __importDefault(require("@/components/ToastDemo"));
function Home() {
    return (React.createElement("div", { className: "flex flex-col min-h-screen bg-gray-50" },
        React.createElement("header", { className: "bg-white shadow-sm" },
            React.createElement("div", { className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center" },
                React.createElement("div", { className: "flex items-center" },
                    React.createElement("svg", { className: "h-8 w-8 text-purple-600", viewBox: "0 0 24 24", fill: "none", xmlns: "http://www.w3.org/2000/svg" },
                        React.createElement("path", { d: "M9 6L15 12L9 18", stroke: "currentColor", strokeWidth: "2", strokeLinecap: "round", strokeLinejoin: "round" })),
                    React.createElement("span", { className: "ml-2 text-2xl font-bold text-gray-900" }, "Nexus-Infinity")),
                React.createElement("nav", null,
                    React.createElement(link_1.default, { href: "/submit-story", className: "text-gray-500 hover:text-gray-900 mx-3" }, "Submit Story"),
                    React.createElement(link_1.default, { href: "/stories", className: "text-gray-500 hover:text-gray-900 mx-3" }, "View Stories"),
                    React.createElement(link_1.default, { href: "/dashboard", className: "text-gray-500 hover:text-gray-900 mx-3" }, "Dashboard"),
                    React.createElement(link_1.default, { href: "/report", className: "text-gray-500 hover:text-gray-900 mx-3" }, "Urgent Report")))),
        React.createElement("main", { className: "flex-grow container mx-auto px-4 py-8" },
            React.createElement("h1", { className: "text-4xl font-bold text-center mb-4" }, "Welcome to Nexus-Infinity Platform"),
            React.createElement("p", { className: "text-xl text-center text-gray-600 mb-8" }, "Share your story and make a difference in our community."),
            React.createElement("div", { className: "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8" },
                React.createElement(card_1.Card, null,
                    React.createElement(card_1.CardHeader, null,
                        React.createElement(card_1.CardTitle, { className: "flex items-center" },
                            React.createElement(lucide_react_1.PenTool, { className: "h-6 w-6 text-purple-600 mr-2" }),
                            "Submit Your Story")),
                    React.createElement(card_1.CardContent, null,
                        React.createElement("p", { className: "text-gray-600 mb-4" }, "Share your experiences and insights with our community."),
                        React.createElement(button_1.Button, { asChild: true, className: "w-full" },
                            React.createElement(link_1.default, { href: "/submit-story" }, "Submit a Story")))),
                React.createElement(card_1.Card, null,
                    React.createElement(card_1.CardHeader, null,
                        React.createElement(card_1.CardTitle, { className: "flex items-center" },
                            React.createElement(lucide_react_1.BookOpen, { className: "h-6 w-6 text-green-600 mr-2" }),
                            "Read Stories")),
                    React.createElement(card_1.CardContent, null,
                        React.createElement("p", { className: "text-gray-600 mb-4" }, "Explore inspiring stories from our community members."),
                        React.createElement(button_1.Button, { asChild: true, variant: "outline", className: "w-full" },
                            React.createElement(link_1.default, { href: "/stories" }, "View Stories")))),
                React.createElement(card_1.Card, null,
                    React.createElement(card_1.CardHeader, null,
                        React.createElement(card_1.CardTitle, { className: "flex items-center" },
                            React.createElement(lucide_react_1.LayoutDashboard, { className: "h-6 w-6 text-blue-600 mr-2" }),
                            "Your Dashboard")),
                    React.createElement(card_1.CardContent, null,
                        React.createElement("p", { className: "text-gray-600 mb-4" }, "Manage your stories and see your impact on the community."),
                        React.createElement(button_1.Button, { asChild: true, variant: "outline", className: "w-full" },
                            React.createElement(link_1.default, { href: "/dashboard" }, "Go to Dashboard")))),
                React.createElement(card_1.Card, null,
                    React.createElement(card_1.CardHeader, null,
                        React.createElement(card_1.CardTitle, { className: "flex items-center" },
                            React.createElement(lucide_react_1.AlertTriangle, { className: "h-6 w-6 text-red-600 mr-2" }),
                            "Urgent Report")),
                    React.createElement(card_1.CardContent, null,
                        React.createElement("p", { className: "text-gray-600 mb-4" }, "View and respond to urgent community issues and reports."),
                        React.createElement(button_1.Button, { asChild: true, variant: "outline", className: "w-full bg-red-100 hover:bg-red-200 text-red-600 border-red-200" },
                            React.createElement(link_1.default, { href: "/report" }, "View Urgent Report"))))),
            React.createElement("div", { className: "mb-8" },
                React.createElement(NewFeature_1.default, null)),
            React.createElement("div", { className: "mb-8" },
                React.createElement(ToastDemo_1.default, null))),
        React.createElement("footer", { className: "bg-white mt-12" },
            React.createElement("div", { className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 text-center text-gray-500" }, "\u00A9 2023 Nexus-Infinity Platform. All rights reserved."))));
}

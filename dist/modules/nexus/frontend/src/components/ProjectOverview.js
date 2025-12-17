"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var lucide_react_1 = require("lucide-react");
var card_1 = require("@/components/ui/card");
var tabs_1 = require("@/components/ui/tabs");
var ProjectOverview = function (_a) {
    var _b = _a.title, title = _b === void 0 ? "Nexus Module Overview" : _b, _c = _a.description, description = _c === void 0 ? "An overview for developers and stakeholders" : _c, _d = _a.features, features = _d === void 0 ? [
        { icon: lucide_react_1.Folder, title: "Modular Architecture", description: "Separate, independent modules for easy development and scaling" },
        { icon: lucide_react_1.Code, title: "Cross-Platform Compatibility", description: "Works seamlessly across web, mobile, and desktop platforms" },
        { icon: lucide_react_1.Database, title: "Scalable Data Management", description: "Efficiently handle growing amounts of information" },
        { icon: lucide_react_1.Cloud, title: "Cloud-Native Design", description: "Optimized for deployment on various cloud services" },
        { icon: lucide_react_1.Settings, title: "Flexible Configuration", description: "Easily adjust settings for different environments" },
        { icon: lucide_react_1.Terminal, title: "Integrated DevOps", description: "Streamlined development and deployment processes" },
        { icon: lucide_react_1.Users, title: "Collaboration-Focused", description: "Built for effective teamwork and knowledge sharing" },
        { icon: lucide_react_1.Zap, title: "AI-Powered Features", description: "Leverage artificial intelligence for enhanced capabilities" }
    ] : _d;
    return (react_1.default.createElement("div", { className: "max-w-4xl mx-auto p-6 space-y-8 sm:px-4" },
        react_1.default.createElement("h1", { className: "text-3xl font-bold text-center mb-2" }, title),
        react_1.default.createElement(card_1.Card, { className: "w-full" },
            react_1.default.createElement(card_1.CardHeader, { className: "text-center" },
                react_1.default.createElement(card_1.CardTitle, { className: "text-2xl mb-2" }, "Nexus Module: Core of the Universal Framework"),
                react_1.default.createElement(card_1.CardDescription, null, description)),
            react_1.default.createElement(card_1.CardContent, null,
                react_1.default.createElement(tabs_1.Tabs, { defaultValue: "general", className: "w-full" },
                    react_1.default.createElement(tabs_1.TabsList, { className: "grid w-full grid-cols-2 mb-4" },
                        react_1.default.createElement(tabs_1.TabsTrigger, { value: "general" }, "General Overview"),
                        react_1.default.createElement(tabs_1.TabsTrigger, { value: "technical" }, "Technical Details")),
                    react_1.default.createElement(tabs_1.TabsContent, { value: "general", className: "space-y-4" },
                        react_1.default.createElement("p", { className: "text-muted-foreground" }, "The Nexus module serves as the central hub of the Universal Framework, integrating key functionalities and providing a foundation for scalable, cross-platform application development. It embodies the framework's principles of modularity, flexibility, and innovation."),
                        react_1.default.createElement("h3", { className: "text-xl font-semibold mb-2" }, "Key Features:"),
                        react_1.default.createElement("ul", { className: "space-y-3" }, features.map(function (feature, index) { return (react_1.default.createElement("li", { key: index, className: "flex items-center space-x-3" },
                            react_1.default.createElement(feature.icon, { className: "w-6 h-6 text-primary" }),
                            react_1.default.createElement("span", null,
                                react_1.default.createElement("strong", { className: "text-primary" },
                                    feature.title,
                                    ":"),
                                ' ',
                                react_1.default.createElement("span", { className: "text-muted-foreground" }, feature.description)))); }))),
                    react_1.default.createElement(tabs_1.TabsContent, { value: "technical", className: "space-y-4" },
                        react_1.default.createElement("p", { className: "text-muted-foreground" }, "The Nexus module is designed with a focus on modularity, scalability, and cross-platform compatibility. It leverages cutting-edge technologies and development practices to create a robust, maintainable, and extensible system."),
                        react_1.default.createElement("h3", { className: "text-xl font-semibold mb-2" }, "Core Components:"),
                        react_1.default.createElement("ul", { className: "list-disc pl-5 space-y-2 text-muted-foreground" },
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "Frontend:"),
                                " React with TypeScript, leveraging Next.js for server-side rendering and optimal performance."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "Backend:"),
                                " Node.js with Express, following a layered architecture (routes, controllers, services, models)."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "Database:"),
                                " MongoDB for flexible document storage, with Mongoose for object modeling."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "API:"),
                                " GraphQL for efficient, type-safe data querying and manipulation."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "State Management:"),
                                " Redux for predictable state updates, with Redux Toolkit for simplified logic."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "Testing:"),
                                " Jest for unit and integration testing, Cypress for end-to-end testing."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "CI/CD:"),
                                " GitHub Actions for automated testing, building, and deployment processes."),
                            react_1.default.createElement("li", null,
                                react_1.default.createElement("strong", { className: "text-primary" }, "Containerization:"),
                                " Docker for consistent development and production environments."))))))));
};
exports.default = ProjectOverview;

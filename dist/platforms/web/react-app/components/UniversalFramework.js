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
exports.default = UniversalFrameworkDashboard;
var react_1 = __importStar(require("react"));
var image_1 = __importDefault(require("next/image"));
var card_1 = require("@/components/ui/card");
var progress_1 = require("@/components/ui/progress");
var tabs_1 = require("@/components/ui/tabs");
var lucide_react_1 = require("lucide-react");
var alert_1 = require("@/components/ui/alert");
var button_1 = require("@/components/ui/button");
var projectStructure = [
    { name: "ai", icon: lucide_react_1.Folder, description: "AI-related components" },
    { name: "backend", icon: lucide_react_1.Folder, description: "Backend services" },
    { name: "frontend", icon: lucide_react_1.Folder, description: "Frontend application" },
    { name: "nexus", icon: lucide_react_1.Folder, description: "Core Nexus components" },
    { name: "package.json", icon: lucide_react_1.FileText, description: "Node.js project configuration" },
    { name: "requirements.txt", icon: lucide_react_1.FileText, description: "Python dependencies" },
];
var technologies = [
    "React", "Node.js", "Python", "Next.js", "Express", "MongoDB"
];
var storageServices = [
    { name: "Local Drive (C:)", usage: 70, color: "bg-yellow-500", type: "local", icon: lucide_react_1.HardDrive },
    { name: "Cloud Storage", usage: 55, color: "bg-blue-500", type: "cloud", icon: lucide_react_1.Cloud },
    { name: "Mobile Devices", usage: 80, color: "bg-purple-500", type: "device", icon: lucide_react_1.Smartphone },
];
function UniversalFrameworkDashboard() {
    var _a = (0, react_1.useState)("overview"), activeTab = _a[0], setActiveTab = _a[1];
    return (react_1.default.createElement("div", { className: "grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]" },
        react_1.default.createElement("main", { className: "flex flex-col gap-8 row-start-2 items-center w-full max-w-6xl" },
            react_1.default.createElement("div", { className: "flex items-center justify-between w-full" },
                react_1.default.createElement(image_1.default, { className: "dark:invert", src: "https://nextjs.org/icons/next.svg", alt: "Universal Framework logo", width: 180, height: 38, priority: true }),
                react_1.default.createElement("h1", { className: "text-3xl font-bold" }, "Universal Framework Dashboard")),
            react_1.default.createElement(tabs_1.Tabs, { value: activeTab, onValueChange: setActiveTab, className: "w-full" },
                react_1.default.createElement(tabs_1.TabsList, { className: "grid w-full grid-cols-3 mb-6" },
                    react_1.default.createElement(tabs_1.TabsTrigger, { value: "overview" }, "Overview"),
                    react_1.default.createElement(tabs_1.TabsTrigger, { value: "structure" }, "Project Structure"),
                    react_1.default.createElement(tabs_1.TabsTrigger, { value: "storage" }, "Storage Management")),
                react_1.default.createElement(tabs_1.TabsContent, { value: "overview" },
                    react_1.default.createElement("div", { className: "grid grid-cols-1 md:grid-cols-2 gap-6" },
                        react_1.default.createElement(card_1.Card, null,
                            react_1.default.createElement(card_1.CardHeader, null,
                                react_1.default.createElement(card_1.CardTitle, null, "Project Overview"),
                                react_1.default.createElement(card_1.CardDescription, null, "Key components of your Universal Framework")),
                            react_1.default.createElement(card_1.CardContent, null,
                                react_1.default.createElement("h3", { className: "text-lg font-semibold mb-2" }, "Technologies Used"),
                                react_1.default.createElement("ul", { className: "flex flex-wrap gap-2 mb-4" }, technologies.map(function (tech, index) { return (react_1.default.createElement("li", { key: index, className: "bg-primary text-primary-foreground px-3 py-1 rounded-full text-sm" }, tech)); })),
                                react_1.default.createElement("div", { className: "flex items-center space-x-2" },
                                    react_1.default.createElement(lucide_react_1.Package, { className: "w-5 h-5 text-primary" }),
                                    react_1.default.createElement("span", null, "Dependencies managed via npm and requirements.txt")))),
                        react_1.default.createElement(card_1.Card, null,
                            react_1.default.createElement(card_1.CardHeader, null,
                                react_1.default.createElement(card_1.CardTitle, null, "Quick Actions")),
                            react_1.default.createElement(card_1.CardContent, { className: "flex flex-col gap-4" },
                                react_1.default.createElement(button_1.Button, null,
                                    react_1.default.createElement(lucide_react_1.RefreshCw, { className: "mr-2 h-4 w-4" }),
                                    " Sync All Components"),
                                react_1.default.createElement(button_1.Button, null,
                                    react_1.default.createElement(lucide_react_1.Cloud, { className: "mr-2 h-4 w-4" }),
                                    " Deploy to Cloud"),
                                react_1.default.createElement(button_1.Button, null,
                                    react_1.default.createElement(lucide_react_1.Code, { className: "mr-2 h-4 w-4" }),
                                    " Generate Code"),
                                react_1.default.createElement(button_1.Button, null,
                                    react_1.default.createElement(lucide_react_1.BarChart, { className: "mr-2 h-4 w-4" }),
                                    " View Analytics"))))),
                react_1.default.createElement(tabs_1.TabsContent, { value: "structure" },
                    react_1.default.createElement(card_1.Card, null,
                        react_1.default.createElement(card_1.CardHeader, null,
                            react_1.default.createElement(card_1.CardTitle, null, "Project Structure"),
                            react_1.default.createElement(card_1.CardDescription, null, "Key components and structure of your Universal Framework")),
                        react_1.default.createElement(card_1.CardContent, null,
                            react_1.default.createElement("ul", { className: "grid grid-cols-1 md:grid-cols-2 gap-4" }, projectStructure.map(function (item, index) { return (react_1.default.createElement("li", { key: index, className: "flex items-center space-x-2" },
                                react_1.default.createElement(item.icon, { className: "w-5 h-5 text-primary" }),
                                react_1.default.createElement("span", { className: "font-medium" }, item.name),
                                react_1.default.createElement("span", { className: "text-sm text-muted-foreground" },
                                    "- ",
                                    item.description))); }))))),
                react_1.default.createElement(tabs_1.TabsContent, { value: "storage" },
                    react_1.default.createElement(card_1.Card, null,
                        react_1.default.createElement(card_1.CardHeader, null,
                            react_1.default.createElement(card_1.CardTitle, null, "Storage Management"),
                            react_1.default.createElement(card_1.CardDescription, null, "Overview of storage usage across different services")),
                        react_1.default.createElement(card_1.CardContent, null, storageServices.map(function (service) { return (react_1.default.createElement("div", { key: service.name, className: "mb-4" },
                            react_1.default.createElement("div", { className: "flex justify-between mb-1" },
                                react_1.default.createElement("span", { className: "flex items-center" },
                                    react_1.default.createElement(service.icon, { className: "mr-2 h-4 w-4" }),
                                    service.name),
                                react_1.default.createElement("span", null,
                                    service.usage,
                                    "%")),
                            react_1.default.createElement(progress_1.Progress, { value: service.usage, className: service.color }))); }))))),
            react_1.default.createElement(card_1.Card, { className: "w-full" },
                react_1.default.createElement(card_1.CardHeader, null,
                    react_1.default.createElement(card_1.CardTitle, null, "System Status")),
                react_1.default.createElement(card_1.CardContent, null,
                    react_1.default.createElement(alert_1.Alert, { variant: "default", className: "mb-4" },
                        react_1.default.createElement(lucide_react_1.AlertCircle, { className: "h-4 w-4" }),
                        react_1.default.createElement(alert_1.AlertTitle, null, "System Update Available"),
                        react_1.default.createElement(alert_1.AlertDescription, null, "A new version of Universal Framework is available. Please update to access the latest features.")),
                    react_1.default.createElement("div", { className: "flex items-center justify-between" },
                        react_1.default.createElement("span", null, "Last Sync: 5 minutes ago"),
                        react_1.default.createElement(button_1.Button, { variant: "outline" },
                            react_1.default.createElement(lucide_react_1.Settings, { className: "mr-2 h-4 w-4" }),
                            " Advanced Settings"))))),
        react_1.default.createElement("footer", { className: "row-start-3 flex gap-6 flex-wrap items-center justify-center" },
            react_1.default.createElement("a", { className: "flex items-center gap-2 hover:underline hover:underline-offset-4", href: "https://github.com/your-repo/universal-framework", target: "_blank", rel: "noopener noreferrer" },
                react_1.default.createElement(image_1.default, { src: "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png", alt: "GitHub icon", width: 16, height: 16 }),
                "GitHub Repository"),
            react_1.default.createElement("a", { className: "flex items-center gap-2 hover:underline hover:underline-offset-4", href: "https://your-docs-url.com", target: "_blank", rel: "noopener noreferrer" },
                react_1.default.createElement(lucide_react_1.FileText, { className: "h-4 w-4" }),
                "Documentation"),
            react_1.default.createElement("a", { className: "flex items-center gap-2 hover:underline hover:underline-offset-4", href: "https://your-community-url.com", target: "_blank", rel: "noopener noreferrer" },
                react_1.default.createElement(lucide_react_1.AlertCircle, { className: "h-4 w-4" }),
                "Community Support"))));
}

"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var lucide_react_1 = require("lucide-react");
var ProjectOverview_1 = __importDefault(require("../components/ProjectOverview"));
var ProjectOverviewPage = function () {
    var customFeatures = [
        { icon: lucide_react_1.Folder, title: "Modular Architecture", description: "Separate, independent modules for easy development and scaling" },
        { icon: lucide_react_1.Code, title: "Cross-Platform Compatibility", description: "Works seamlessly across web, mobile, and desktop platforms" },
        { icon: lucide_react_1.Database, title: "Scalable Data Management", description: "Efficiently handle growing amounts of information" },
        { icon: lucide_react_1.Cloud, title: "Cloud-Native Design", description: "Optimized for deployment on various cloud services" },
        { icon: lucide_react_1.Settings, title: "Flexible Configuration", description: "Easily adjust settings for different environments" },
        { icon: lucide_react_1.Terminal, title: "Integrated DevOps", description: "Streamlined development and deployment processes" },
        { icon: lucide_react_1.Users, title: "Collaboration-Focused", description: "Built for effective teamwork and knowledge sharing" },
        { icon: lucide_react_1.Zap, title: "AI-Powered Features", description: "Leverage artificial intelligence for enhanced capabilities" }
    ];
    return (react_1.default.createElement("div", { className: "max-w-5xl mx-auto p-6 space-y-8 sm:px-4" },
        react_1.default.createElement(ProjectOverview_1.default, { title: "Custom Nexus Module Overview", description: "Custom overview for the Nexus module, tailored for stakeholders and developers", features: customFeatures })));
};
exports.default = ProjectOverviewPage;

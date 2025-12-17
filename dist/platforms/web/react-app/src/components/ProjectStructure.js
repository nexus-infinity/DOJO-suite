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
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importStar(require("react"));
var lucide_react_1 = require("lucide-react");
var projectStructure = {
    name: "universal-framework",
    children: [
        { name: "AI_IMPLEMENTATION_PLAN.md" },
        { name: "AI_INTEGRATION.md" },
        { name: "LICENSE" },
        { name: "README.md" },
        {
            name: "platforms",
            children: [
                { name: "desktop" },
                { name: "mobile" },
                { name: "smart-devices" },
                { name: "tv" },
                { name: "wearables" },
                {
                    name: "web",
                    children: [
                        {
                            name: "react-app",
                            children: [
                                { name: "public" },
                                {
                                    name: "src",
                                    children: [
                                        { name: "components" },
                                        { name: "pages" },
                                        { name: "styles" },
                                        { name: "utils" },
                                        { name: "App.tsx" },
                                        { name: "index.tsx" }
                                    ]
                                },
                                { name: "package.json" },
                                { name: "tsconfig.json" },
                                { name: "README.md" }
                            ]
                        }
                    ]
                }
            ]
        },
        { name: "ci-cd" },
        { name: "config" },
        { name: "core" },
        { name: "docs" },
        { name: "modules" },
        { name: "node_modules" },
        { name: "package.json" },
        { name: "package-lock.json" },
        { name: "playground" },
        { name: "shared" },
        { name: "tests" },
        { name: "universal-framework.txt" }
    ]
};
var TreeNode = function (_a) {
    var node = _a.node;
    var _b = (0, react_1.useState)(false), isExpanded = _b[0], setIsExpanded = _b[1];
    var hasChildren = node.children && node.children.length > 0;
    return (react_1.default.createElement("div", null,
        react_1.default.createElement("div", { className: "flex items-center cursor-pointer py-1", onClick: function () { return hasChildren && setIsExpanded(!isExpanded); } },
            hasChildren ? (isExpanded ? react_1.default.createElement(lucide_react_1.ChevronDown, { className: "w-4 h-4 mr-1" }) : react_1.default.createElement(lucide_react_1.ChevronRight, { className: "w-4 h-4 mr-1" })) : (react_1.default.createElement("span", { className: "w-4 h-4 mr-1" })),
            hasChildren ? react_1.default.createElement(lucide_react_1.Folder, { className: "w-4 h-4 mr-2 text-yellow-500" }) : react_1.default.createElement(lucide_react_1.File, { className: "w-4 h-4 mr-2 text-gray-500" }),
            react_1.default.createElement("span", null, node.name)),
        isExpanded && node.children && (react_1.default.createElement("div", { className: "ml-6" }, node.children.map(function (childNode, index) { return (react_1.default.createElement(TreeNode, { key: index, node: childNode })); })))));
};
var ProjectStructure = function () {
    return (react_1.default.createElement("div", { className: "bg-white shadow overflow-hidden sm:rounded-lg" },
        react_1.default.createElement("div", { className: "px-4 py-5 sm:px-6" },
            react_1.default.createElement("h1", { className: "text-3xl font-bold text-gray-900" }, "Project Structure"),
            react_1.default.createElement("p", { className: "mt-1 max-w-2xl text-sm text-gray-500" }, "An interactive view of the Universal Framework project structure")),
        react_1.default.createElement("div", { className: "border-t border-gray-200 px-4 py-5 sm:p-0" },
            react_1.default.createElement("div", { className: "sm:divide-y sm:divide-gray-200" },
                react_1.default.createElement("div", { className: "py-4 sm:py-5 sm:grid sm:grid-cols-3 sm:gap-4 sm:px-6" },
                    react_1.default.createElement("dt", { className: "text-sm font-medium text-gray-500" }, "Directory Tree"),
                    react_1.default.createElement("dd", { className: "mt-1 text-sm text-gray-900 sm:mt-0 sm:col-span-2" },
                        react_1.default.createElement("div", { className: "border rounded p-4 bg-gray-50" },
                            react_1.default.createElement(TreeNode, { node: projectStructure }))))))));
};
exports.default = ProjectStructure;

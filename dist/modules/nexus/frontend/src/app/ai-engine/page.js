"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = Home;
var AIFileManager_1 = require("../../components/AIFileManager");
function Home() {
    return (React.createElement("main", { className: "flex min-h-screen flex-col items-center justify-between p-24" },
        React.createElement("h1", { className: "text-4xl font-bold mb-8" }, "Nexus-Infinity AI Engine"),
        React.createElement(AIFileManager_1.AIFileManager, null)));
}

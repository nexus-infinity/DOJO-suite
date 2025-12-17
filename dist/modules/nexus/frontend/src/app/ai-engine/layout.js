"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.metadata = void 0;
exports.default = RootLayout;
var google_1 = require("next/font/google");
var inter = (0, google_1.Inter)({ subsets: ['latin'] });
exports.metadata = {
    title: 'Nexus-Infinity AI Engine',
    description: 'AI-powered file management system',
};
function RootLayout(_a) {
    var children = _a.children;
    return (React.createElement("html", { lang: "en" },
        React.createElement("body", { className: inter.className }, children)));
}

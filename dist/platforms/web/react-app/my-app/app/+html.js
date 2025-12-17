"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = Root;
var html_1 = require("expo-router/html");
/**
 * This file is web-only and used to configure the root HTML for every web page during static rendering.
 * The contents of this function only run in Node.js environments and do not have access to the DOM or browser APIs.
 */
function Root(_a) {
    var children = _a.children;
    return (React.createElement("html", { lang: "en" },
        React.createElement("head", null,
            React.createElement("meta", { charSet: "utf-8" }),
            React.createElement("meta", { httpEquiv: "X-UA-Compatible", content: "IE=edge" }),
            React.createElement("meta", { name: "viewport", content: "width=device-width, initial-scale=1, shrink-to-fit=no" }),
            React.createElement(html_1.ScrollViewStyleReset, null),
            React.createElement("style", { dangerouslySetInnerHTML: { __html: responsiveBackground } })),
        React.createElement("body", null, children)));
}
var responsiveBackground = "\nbody {\n  background-color: #fff;\n}\n@media (prefers-color-scheme: dark) {\n  body {\n    background-color: #000;\n  }\n}";

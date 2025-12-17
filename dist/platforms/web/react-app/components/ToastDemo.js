'use client';
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = ToastDemo;
var react_1 = require("react");
var button_1 = require("@/components/ui/button");
var use_toast_1 = require("@/components/ui/use-toast");
function ToastDemo() {
    var toast = (0, use_toast_1.useToast)().toast;
    var _a = (0, react_1.useState)(0), count = _a[0], setCount = _a[1];
    var showToast = function () {
        setCount(function (prevCount) { return prevCount + 1; });
        toast({
            title: "Toast Triggered",
            description: "This toast has been shown ".concat(count + 1, " times."),
        });
    };
    return (React.createElement("div", { className: "p-4" },
        React.createElement("h2", { className: "text-2xl font-bold mb-4" }, "Toast Demo"),
        React.createElement(button_1.Button, { onClick: showToast }, "Show Toast")));
}

"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var react_1 = __importDefault(require("react"));
var Button = function (_a) {
    var label = _a.label, onClick = _a.onClick, _b = _a.variant, variant = _b === void 0 ? 'primary' : _b;
    var baseStyles = 'px-4 py-2 rounded font-semibold text-sm';
    var variantStyles = {
        primary: 'bg-blue-500 text-white hover:bg-blue-600',
        secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300',
        tertiary: 'bg-transparent text-blue-500 hover:underline'
    };
    return (react_1.default.createElement("button", { className: "".concat(baseStyles, " ").concat(variantStyles[variant]), onClick: onClick }, label));
};
exports.default = Button;

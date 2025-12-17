"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = NewFeature;
var react_1 = __importDefault(require("react"));
var card_1 = require("@/components/ui/card");
function NewFeature() {
    return (react_1.default.createElement(card_1.Card, null,
        react_1.default.createElement(card_1.CardHeader, null,
            react_1.default.createElement(card_1.CardTitle, null, "New Feature")),
        react_1.default.createElement(card_1.CardContent, null,
            react_1.default.createElement("p", null, "This is a new feature we've added to our Nexus-Infinity project."))));
}

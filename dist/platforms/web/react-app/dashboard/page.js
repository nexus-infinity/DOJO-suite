'use client';
"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = Dashboard;
var react_1 = require("react");
var button_1 = require("@/components/ui/button");
var card_1 = require("@/components/ui/card");
var table_1 = require("@/components/ui/table");
var lucide_react_1 = require("lucide-react");
var link_1 = __importDefault(require("next/link"));
var EvidenceSubmissionPlatform_1 = __importDefault(require("@/components/EvidenceSubmissionPlatform"));
// Mock data for demonstration
var mockUserStories = [
    { id: 1, title: "My Journey to Recovery", createdAt: "2023-06-15", status: "published" },
    { id: 2, title: "Fighting for Equality", createdAt: "2023-06-20", status: "under review" },
    { id: 3, title: "A Voice for the Voiceless", createdAt: "2023-06-25", status: "draft" },
];
function Dashboard() {
    var _a = (0, react_1.useState)(mockUserStories), userStories = _a[0], setUserStories = _a[1];
    var _b = (0, react_1.useState)(false), showSubmissionForm = _b[0], setShowSubmissionForm = _b[1];
    // In a real application, you would fetch the user's stories from your API here
    (0, react_1.useEffect)(function () {
        // Simulating an API call
        setTimeout(function () {
            setUserStories(mockUserStories);
        }, 1000);
    }, []);
    var handleDelete = function (id) {
        // In a real application, you would call your API to delete the story
        setUserStories(userStories.filter(function (story) { return story.id !== id; }));
    };
    return (React.createElement("div", { className: "container mx-auto px-4 py-8" },
        React.createElement("h1", { className: "text-3xl font-bold mb-6" }, "Your Dashboard"),
        React.createElement("div", { className: "grid gap-6 md:grid-cols-2 lg:grid-cols-3 mb-6" },
            React.createElement(card_1.Card, null,
                React.createElement(card_1.CardHeader, null,
                    React.createElement(card_1.CardTitle, null, "Total Stories")),
                React.createElement(card_1.CardContent, null,
                    React.createElement("p", { className: "text-3xl font-bold" }, userStories.length))),
            React.createElement(card_1.Card, null,
                React.createElement(card_1.CardHeader, null,
                    React.createElement(card_1.CardTitle, null, "Published Stories")),
                React.createElement(card_1.CardContent, null,
                    React.createElement("p", { className: "text-3xl font-bold" }, userStories.filter(function (story) { return story.status === 'published'; }).length))),
            React.createElement(card_1.Card, null,
                React.createElement(card_1.CardHeader, null,
                    React.createElement(card_1.CardTitle, null, "Stories Under Review")),
                React.createElement(card_1.CardContent, null,
                    React.createElement("p", { className: "text-3xl font-bold" }, userStories.filter(function (story) { return story.status === 'under review'; }).length)))),
        React.createElement(card_1.Card, { className: "mb-6" },
            React.createElement(card_1.CardHeader, null,
                React.createElement(card_1.CardTitle, null, "Your Stories")),
            React.createElement(card_1.CardContent, null,
                React.createElement(table_1.Table, null,
                    React.createElement(table_1.TableHeader, null,
                        React.createElement(table_1.TableRow, null,
                            React.createElement(table_1.TableHead, null, "Title"),
                            React.createElement(table_1.TableHead, null, "Created At"),
                            React.createElement(table_1.TableHead, null, "Status"),
                            React.createElement(table_1.TableHead, null, "Actions"))),
                    React.createElement(table_1.TableBody, null, userStories.map(function (story) { return (React.createElement(table_1.TableRow, { key: story.id },
                        React.createElement(table_1.TableCell, null, story.title),
                        React.createElement(table_1.TableCell, null, story.createdAt),
                        React.createElement(table_1.TableCell, null, story.status),
                        React.createElement(table_1.TableCell, null,
                            React.createElement("div", { className: "flex space-x-2" },
                                React.createElement(button_1.Button, { variant: "outline", size: "sm" },
                                    React.createElement(lucide_react_1.Edit2, { className: "h-4 w-4 mr-2" }),
                                    "Edit"),
                                React.createElement(button_1.Button, { variant: "outline", size: "sm", onClick: function () { return handleDelete(story.id); } },
                                    React.createElement(lucide_react_1.Trash2, { className: "h-4 w-4 mr-2" }),
                                    "Delete"))))); }))))),
        React.createElement("div", { className: "mb-6" },
            React.createElement(button_1.Button, { onClick: function () { return setShowSubmissionForm(!showSubmissionForm); } }, showSubmissionForm ? 'Hide Submission Form' : 'Submit New Evidence')),
        showSubmissionForm && (React.createElement(card_1.Card, { className: "mb-6" },
            React.createElement(card_1.CardHeader, null,
                React.createElement(card_1.CardTitle, null, "Submit New Evidence")),
            React.createElement(card_1.CardContent, null,
                React.createElement(EvidenceSubmissionPlatform_1.default, null)))),
        React.createElement("div", null,
            React.createElement(button_1.Button, { asChild: true },
                React.createElement(link_1.default, { href: "/submit-story" }, "Submit New Story")))));
}

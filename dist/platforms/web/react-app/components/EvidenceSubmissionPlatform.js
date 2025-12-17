'use client';
"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g = Object.create((typeof Iterator === "function" ? Iterator : Object).prototype);
    return g.next = verb(0), g["throw"] = verb(1), g["return"] = verb(2), typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (g && (g = 0, op[0] && (_ = 0)), _) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = EvidenceSubmissionPlatform;
var react_1 = require("react");
var lucide_react_1 = require("lucide-react");
var framer_motion_1 = require("framer-motion");
var button_1 = require("@/components/ui/button");
var input_1 = require("@/components/ui/input");
var textarea_1 = require("@/components/ui/textarea");
var card_1 = require("@/components/ui/card");
var use_toast_1 = require("@/components/ui/use-toast");
var label_1 = require("@/components/ui/label");
var progress_1 = require("@/components/ui/progress");
function EvidenceSubmissionPlatform() {
    var _this = this;
    var _a = (0, react_1.useState)(null), file = _a[0], setFile = _a[1];
    var _b = (0, react_1.useState)(''), title = _b[0], setTitle = _b[1];
    var _c = (0, react_1.useState)(''), description = _c[0], setDescription = _c[1];
    var _d = (0, react_1.useState)(''), location = _d[0], setLocation = _d[1];
    var _e = (0, react_1.useState)('idle'), submissionStatus = _e[0], setSubmissionStatus = _e[1];
    var _f = (0, react_1.useState)({}), errors = _f[0], setErrors = _f[1];
    var _g = (0, react_1.useState)(0), uploadProgress = _g[0], setUploadProgress = _g[1];
    var toast = (0, use_toast_1.useToast)().toast;
    var handleFileChange = function (event) {
        if (event.target.files && event.target.files[0]) {
            setFile(event.target.files[0]);
        }
    };
    var validateForm = function () {
        var newErrors = {};
        if (!title.trim())
            newErrors.title = 'Title is required';
        if (!description.trim())
            newErrors.description = 'Description is required';
        if (!file)
            newErrors.file = 'File is required';
        setErrors(newErrors);
        return Object.keys(newErrors).length === 0;
    };
    var handleSubmit = function (event) { return __awaiter(_this, void 0, void 0, function () {
        var progressInterval, error_1;
        return __generator(this, function (_a) {
            switch (_a.label) {
                case 0:
                    event.preventDefault();
                    if (!validateForm())
                        return [2 /*return*/];
                    setSubmissionStatus('submitting');
                    setUploadProgress(0);
                    progressInterval = setInterval(function () {
                        setUploadProgress(function (prevProgress) {
                            if (prevProgress >= 95) {
                                clearInterval(progressInterval);
                                return prevProgress;
                            }
                            return prevProgress + 5;
                        });
                    }, 500);
                    _a.label = 1;
                case 1:
                    _a.trys.push([1, 3, 4, 5]);
                    // Simulating API  call
                    return [4 /*yield*/, new Promise(function (resolve) { return setTimeout(resolve, 3000); })
                        // Here you would typically send the data to your backend
                        // const formData = new FormData()
                        // formData.append('title', title)
                        // formData.append('description', description)
                        // formData.append('location', location)
                        // formData.append('file', file)
                        // const response = await fetch('/api/submit-evidence', {
                        //   method: 'POST',
                        //   body: formData,
                        // })
                        // if (!response.ok) throw new Error('Submission failed')
                    ];
                case 2:
                    // Simulating API  call
                    _a.sent();
                    // Here you would typically send the data to your backend
                    // const formData = new FormData()
                    // formData.append('title', title)
                    // formData.append('description', description)
                    // formData.append('location', location)
                    // formData.append('file', file)
                    // const response = await fetch('/api/submit-evidence', {
                    //   method: 'POST',
                    //   body: formData,
                    // })
                    // if (!response.ok) throw new Error('Submission failed')
                    setSubmissionStatus('success');
                    toast({
                        title: "Evidence Submitted",
                        description: "Your evidence has been successfully submitted.",
                        duration: 5000,
                    });
                    return [3 /*break*/, 5];
                case 3:
                    error_1 = _a.sent();
                    setSubmissionStatus('error');
                    toast({
                        title: "Submission Failed",
                        description: "There was an error submitting your evidence. Please try again.",
                        variant: "destructive",
                        duration: 5000,
                    });
                    return [3 /*break*/, 5];
                case 4:
                    clearInterval(progressInterval);
                    setUploadProgress(100);
                    return [7 /*endfinally*/];
                case 5: return [2 /*return*/];
            }
        });
    }); };
    return (React.createElement(card_1.Card, { className: "w-full max-w-2xl mx-auto" },
        React.createElement(card_1.CardHeader, null,
            React.createElement(card_1.CardTitle, { className: "text-2xl font-bold" }, "Submit Evidence")),
        React.createElement(card_1.CardContent, null,
            React.createElement("form", { onSubmit: handleSubmit, className: "space-y-4" },
                React.createElement("div", { className: "space-y-2" },
                    React.createElement(label_1.Label, { htmlFor: "title" }, "Title"),
                    React.createElement(input_1.Input, { id: "title", value: title, onChange: function (e) { return setTitle(e.target.value); }, className: errors.title ? 'border-red-500' : '' }),
                    errors.title && React.createElement("p", { className: "text-sm text-red-500" }, errors.title)),
                React.createElement("div", { className: "space-y-2" },
                    React.createElement(label_1.Label, { htmlFor: "description" }, "Description"),
                    React.createElement(textarea_1.Textarea, { id: "description", value: description, onChange: function (e) { return setDescription(e.target.value); }, className: errors.description ? 'border-red-500' : '' }),
                    errors.description && React.createElement("p", { className: "text-sm text-red-500" }, errors.description)),
                React.createElement("div", { className: "space-y-2" },
                    React.createElement(label_1.Label, { htmlFor: "location" }, "Location (Optional)"),
                    React.createElement(input_1.Input, { id: "location", value: location, onChange: function (e) { return setLocation(e.target.value); } })),
                React.createElement("div", { className: "space-y-2" },
                    React.createElement(label_1.Label, { htmlFor: "file" }, "Upload File"),
                    React.createElement(input_1.Input, { id: "file", type: "file", onChange: handleFileChange, className: errors.file ? 'border-red-500' : '' }),
                    errors.file && React.createElement("p", { className: "text-sm text-red-500" }, errors.file)),
                React.createElement(framer_motion_1.AnimatePresence, null, submissionStatus === 'submitting' && (React.createElement(framer_motion_1.motion.div, { initial: { opacity: 0, height: 0 }, animate: { opacity: 1, height: 'auto' }, exit: { opacity: 0, height: 0 } },
                    React.createElement(progress_1.Progress, { value: uploadProgress, className: "w-full" })))),
                React.createElement(button_1.Button, { type: "submit", className: "w-full", disabled: submissionStatus === 'submitting' }, submissionStatus === 'submitting' ? (React.createElement(React.Fragment, null,
                    React.createElement(lucide_react_1.Loader2, { className: "mr-2 h-4 w-4 animate-spin" }),
                    "Submitting...")) : (React.createElement(React.Fragment, null,
                    React.createElement(lucide_react_1.Upload, { className: "mr-2 h-4 w-4" }),
                    "Submit Evidence")))),
            React.createElement(framer_motion_1.AnimatePresence, null,
                submissionStatus === 'success' && (React.createElement(framer_motion_1.motion.div, { initial: { opacity: 0 }, animate: { opacity: 1 }, exit: { opacity: 0 }, className: "mt-4 p-4 bg-green-100 text-green-700 rounded-md flex items-center" },
                    React.createElement(lucide_react_1.Check, { className: "mr-2 h-5 w-5" }),
                    "Evidence submitted successfully!")),
                submissionStatus === 'error' && (React.createElement(framer_motion_1.motion.div, { initial: { opacity: 0 }, animate: { opacity: 1 }, exit: { opacity: 0 }, className: "mt-4 p-4 bg-red-100 text-red-700 rounded-md flex items-center" },
                    React.createElement(lucide_react_1.AlertTriangle, { className: "mr-2 h-5 w-5" }),
                    "An error occurred. Please try again."))))));
}

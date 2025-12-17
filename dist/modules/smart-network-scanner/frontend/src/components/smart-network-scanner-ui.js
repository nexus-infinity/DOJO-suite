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
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SmartNetworkScannerUI = SmartNetworkScannerUI;
var react_1 = __importStar(require("react"));
var scanner_1 = require("../services/scanner");
var card_1 = require("@/components/ui/card");
var tabs_1 = require("@/components/ui/tabs");
function SmartNetworkScannerUI() {
    var _this = this;
    var _a = (0, react_1.useState)([]), devices = _a[0], setDevices = _a[1];
    var _b = (0, react_1.useState)(false), isScanning = _b[0], setIsScanning = _b[1];
    var scanner = (0, react_1.useState)(function () { return new scanner_1.SmartNetworkScanner(); })[0];
    (0, react_1.useEffect)(function () {
        var scanNetwork = function () { return __awaiter(_this, void 0, void 0, function () {
            var scannedDevices;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        setIsScanning(true);
                        return [4 /*yield*/, scanner.scanNetwork()];
                    case 1:
                        scannedDevices = _a.sent();
                        setDevices(scannedDevices);
                        setIsScanning(false);
                        return [2 /*return*/];
                }
            });
        }); };
        scanNetwork();
        scanner.monitorNetworkChanges(function (updatedDevices) {
            setDevices(updatedDevices);
        });
        return function () {
            scanner.stopMonitoring();
        };
    }, [scanner]);
    var deviceTypes = __spreadArray([], new Set(devices.map(function (device) { return device.type; })), true);
    return (react_1.default.createElement(card_1.Card, { className: "w-full" },
        react_1.default.createElement(card_1.CardHeader, null,
            react_1.default.createElement(card_1.CardTitle, null, "Smart Network Scanner")),
        react_1.default.createElement(card_1.CardContent, null, isScanning ? (react_1.default.createElement("p", { className: "text-blue-600" }, "Scanning network...")) : (react_1.default.createElement(tabs_1.Tabs, { defaultValue: "all", className: "w-full" },
            react_1.default.createElement(tabs_1.TabsList, { className: "grid w-full grid-cols-2 lg:grid-cols-5" },
                react_1.default.createElement(tabs_1.TabsTrigger, { value: "all" }, "All"),
                deviceTypes.map(function (type) { return (react_1.default.createElement(tabs_1.TabsTrigger, { key: type, value: type }, type)); })),
            react_1.default.createElement(tabs_1.TabsContent, { value: "all" },
                react_1.default.createElement(DeviceList, { devices: devices })),
            deviceTypes.map(function (type) { return (react_1.default.createElement(tabs_1.TabsContent, { key: type, value: type },
                react_1.default.createElement(DeviceList, { devices: devices.filter(function (device) { return device.type === type; }) }))); }))))));
}
function DeviceList(_a) {
    var devices = _a.devices;
    return (react_1.default.createElement("ul", { className: "space-y-2" }, devices.map(function (device) { return (react_1.default.createElement("li", { key: device.id },
        react_1.default.createElement(card_1.Card, null,
            react_1.default.createElement(card_1.CardContent, { className: "p-4" },
                react_1.default.createElement("h3", { className: "font-medium" }, device.name),
                react_1.default.createElement("p", { className: "text-sm text-muted-foreground" },
                    "IP: ",
                    device.ip),
                react_1.default.createElement("p", { className: "text-sm text-muted-foreground" },
                    "Type: ",
                    device.type),
                react_1.default.createElement("p", { className: "text-sm text-muted-foreground" },
                    "Status: ",
                    device.status))))); })));
}

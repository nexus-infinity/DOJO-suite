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
Object.defineProperty(exports, "__esModule", { value: true });
exports.NetworkScannerService = void 0;
var net = __importStar(require("net"));
var os = __importStar(require("os"));
var NetworkScannerService = /** @class */ (function () {
    function NetworkScannerService() {
    }
    NetworkScannerService.prototype.scanNetwork = function () {
        return __awaiter(this, void 0, void 0, function () {
            var devices, interfaces, _i, _a, _b, name_1, netInterface, _c, netInterface_1, info, subnet, scannedDevices;
            return __generator(this, function (_d) {
                switch (_d.label) {
                    case 0:
                        devices = [];
                        interfaces = os.networkInterfaces();
                        _i = 0, _a = Object.entries(interfaces);
                        _d.label = 1;
                    case 1:
                        if (!(_i < _a.length)) return [3 /*break*/, 6];
                        _b = _a[_i], name_1 = _b[0], netInterface = _b[1];
                        if (!netInterface)
                            return [3 /*break*/, 5];
                        _c = 0, netInterface_1 = netInterface;
                        _d.label = 2;
                    case 2:
                        if (!(_c < netInterface_1.length)) return [3 /*break*/, 5];
                        info = netInterface_1[_c];
                        if (!(info.family === 'IPv4' && !info.internal)) return [3 /*break*/, 4];
                        subnet = this.getSubnet(info.address, info.netmask);
                        return [4 /*yield*/, this.scanSubnet(subnet)];
                    case 3:
                        scannedDevices = _d.sent();
                        devices.push.apply(devices, scannedDevices);
                        _d.label = 4;
                    case 4:
                        _c++;
                        return [3 /*break*/, 2];
                    case 5:
                        _i++;
                        return [3 /*break*/, 1];
                    case 6: return [2 /*return*/, devices];
                }
            });
        });
    };
    NetworkScannerService.prototype.getSubnet = function (ip, netmask) {
        var ipParts = ip.split('.').map(Number);
        var maskParts = netmask.split('.').map(Number);
        return ipParts.map(function (part, i) { return part & maskParts[i]; }).join('.');
    };
    NetworkScannerService.prototype.scanSubnet = function (subnet) {
        return __awaiter(this, void 0, void 0, function () {
            var devices, promises, _loop_1, this_1, i;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        devices = [];
                        promises = [];
                        _loop_1 = function (i) {
                            var ip = "".concat(subnet, ".").concat(i);
                            promises.push(this_1.pingHost(ip).then(function (isAlive) {
                                if (isAlive) {
                                    devices.push({
                                        id: ip,
                                        ip: ip,
                                        name: "Unknown Device (".concat(ip, ")"),
                                        type: 'Unknown',
                                        status: 'online',
                                        lastSeen: new Date().toISOString()
                                    });
                                }
                            }));
                        };
                        this_1 = this;
                        for (i = 1; i < 255; i++) {
                            _loop_1(i);
                        }
                        return [4 /*yield*/, Promise.all(promises)];
                    case 1:
                        _a.sent();
                        return [2 /*return*/, devices];
                }
            });
        });
    };
    NetworkScannerService.prototype.pingHost = function (ip) {
        return new Promise(function (resolve) {
            var socket = new net.Socket();
            socket.setTimeout(1000);
            socket.on('connect', function () {
                socket.destroy();
                resolve(true);
            }).on('timeout', function () {
                socket.destroy();
                resolve(false);
            }).on('error', function () {
                resolve(false);
            }).connect(80, ip);
        });
    };
    return NetworkScannerService;
}());
exports.NetworkScannerService = NetworkScannerService;

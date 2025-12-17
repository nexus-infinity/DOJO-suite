"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
var express_1 = __importDefault(require("express"));
var network_scanner_controller_1 = require("../controllers/network-scanner-controller");
var router = express_1.default.Router();
var controller = new network_scanner_controller_1.NetworkScannerController();
router.get('/scan', function (req, res) { return controller.scanNetwork(req, res); });
exports.default = router;

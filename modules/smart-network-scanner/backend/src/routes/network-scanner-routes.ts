import express from 'express';
import { NetworkScannerController } from '../controllers/network-scanner-controller';

const router = express.Router();
const controller = new NetworkScannerController();

router.get('/scan', (req, res) => controller.scanNetwork(req, res));

export default router;
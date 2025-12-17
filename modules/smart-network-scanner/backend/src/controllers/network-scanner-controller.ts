import { Request, Response } from 'express';
import { NetworkScannerService } from '../services/network-scanner';

export class NetworkScannerController {
  private scannerService: NetworkScannerService;

  constructor() {
    this.scannerService = new NetworkScannerService();
  }

  async scanNetwork(req: Request, res: Response): Promise<void> {
    try {
      const devices = await this.scannerService.scanNetwork();
      res.json(devices);
    } catch (error) {
      console.error('Error scanning network:', error);
      res.status(500).json({ error: 'An error occurred while scanning the network' });
    }
  }
}
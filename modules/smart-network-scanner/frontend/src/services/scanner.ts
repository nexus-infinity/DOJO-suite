import { Device } from '../types/device';

export class SmartNetworkScanner {
  private isMonitoring: boolean = false;

  async scanNetwork(): Promise<Device[]> {
    const response = await fetch('/api/network-scanner/scan');
    if (!response.ok) {
      throw new Error('Network scan failed');
    }
    return response.json();
  }

  async monitorNetworkChanges(callback: (devices: Device[]) => void): Promise<void> {
    this.isMonitoring = true;
    while (this.isMonitoring) {
      const devices = await this.scanNetwork();
      callback(devices);
      await new Promise(resolve => setTimeout(resolve, 60000)); // Scan every minute
    }
  }

  stopMonitoring(): void {
    this.isMonitoring = false;
  }
}
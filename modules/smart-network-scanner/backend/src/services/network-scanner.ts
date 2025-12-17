import { Device } from '../../../shared/types/device';
import * as net from 'net';
import * as os from 'os';

export class NetworkScannerService {
  async scanNetwork(): Promise<Device[]> {
    const devices: Device[] = [];
    const interfaces = os.networkInterfaces();

    for (const [name, netInterface] of Object.entries(interfaces)) {
      if (!netInterface) continue;

      for (const info of netInterface) {
        if (info.family === 'IPv4' && !info.internal) {
          const subnet = this.getSubnet(info.address, info.netmask);
          const scannedDevices = await this.scanSubnet(subnet);
          devices.push(...scannedDevices);
        }
      }
    }

    return devices;
  }

  private getSubnet(ip: string, netmask: string): string {
    const ipParts = ip.split('.').map(Number);
    const maskParts = netmask.split('.').map(Number);
    return ipParts.map((part, i) => part & maskParts[i]).join('.');
  }

  private async scanSubnet(subnet: string): Promise<Device[]> {
    const devices: Device[] = [];
    const promises: Promise<void>[] = [];

    for (let i = 1; i < 255; i++) {
      const ip = `${subnet}.${i}`;
      promises.push(
        this.pingHost(ip).then(isAlive => {
          if (isAlive) {
            devices.push({
              id: ip,
              ip,
              name: `Unknown Device (${ip})`,
              type: 'Unknown',
              status: 'online',
              lastSeen: new Date().toISOString()
            });
          }
        })
      );
    }

    await Promise.all(promises);
    return devices;
  }

  private pingHost(ip: string): Promise<boolean> {
    return new Promise(resolve => {
      const socket = new net.Socket();
      socket.setTimeout(1000);
      socket.on('connect', () => {
        socket.destroy();
        resolve(true);
      }).on('timeout', () => {
        socket.destroy();
        resolve(false);
      }).on('error', () => {
        resolve(false);
      }).connect(80, ip);
    });
  }
}
export interface Device {
  id: string;
  ip: string;
  name: string;
  type: string;
  status: 'online' | 'offline';
  lastSeen: string;
}
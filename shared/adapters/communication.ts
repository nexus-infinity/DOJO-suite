// Communication service for cross-module messaging
export class Communication {
  static sendMessage(moduleName: string, message: any): void {
    console.log(`Sending message to ${moduleName}: `, message);
    // Add logic to send message between modules
  }

  static receiveMessage(moduleName: string): void {
    console.log(`Receiving message from ${moduleName}`);
    // Add logic to receive and process messages
  }
}

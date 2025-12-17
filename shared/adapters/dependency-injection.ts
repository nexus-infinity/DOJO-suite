// Dependency Injection service for decoupling modules
export class DependencyInjector {
  private static services = new Map<string, any>();

  static registerService(name: string, service: any) {
    DependencyInjector.services.set(name, service);
  }

  static getService(name: string) {
    return DependencyInjector.services.get(name);
  }
}

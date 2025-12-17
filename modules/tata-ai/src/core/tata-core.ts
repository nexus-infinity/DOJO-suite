import { Communication } from '../../../shared/adapters/communication';
import { DependencyInjector } from '../../../shared/adapters/dependency-injection';

export function initialize() {
  const aiService = DependencyInjector.getService('AIService');
  if (aiService) {
    aiService.runModel({ /* your data */ });
  } else {
    console.error('AIService not available');
  }
}

export function processInput(data: any) {
  Communication.sendMessage('bear-project', data);
}

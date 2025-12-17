import { initialize } from '../../modules/tata-ai/src/core/tata-core';
import { Communication } from '../../shared/adapters/communication';

test('Tata AI -> Backend Communication Test', () => {
  const data = { test: 'sample-data' };
  
  // Initialize Tata AI and process the input data
  initialize();
  
  // Simulate sending data to another module via Communication service
  const consoleSpy = jest.spyOn(console, 'log');
  Communication.sendMessage('backend-module', data);
  
  // Check that the message was sent
  expect(consoleSpy).toHaveBeenCalledWith('Sending message to backend-module: ', data);
});

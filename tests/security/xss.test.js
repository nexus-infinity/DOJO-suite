import { escapeHTML } from '@modules/tata-ai/src/utils/security';

test('Escapes HTML to prevent XSS', () => {
  const maliciousInput = '<script>alert("XSS")</script>';
  const escapedOutput = escapeHTML(maliciousInput);
  expect(escapedOutput).not.toContain('<script>');
});

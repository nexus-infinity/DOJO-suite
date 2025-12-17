import { escapeHTML } from '../src/utils/security';

test('Escapes HTML to prevent XSS', () => {
  const maliciousInput = '<script>alert("XSS")</script>';
  const escapedOutput = escapeHTML(maliciousInput);
  expect(escapedOutput).toBe('&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;');
});
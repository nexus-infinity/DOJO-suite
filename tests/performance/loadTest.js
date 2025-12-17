// tests/performance/loadTest.js
test('Page loads in acceptable time', () => {
  const start = performance.now();
  // Simulate page load
  const end = performance.now();
  const duration = end - start;
  expect(duration).toBeLessThan(2000); // Example: Expect load time under 2 seconds
});

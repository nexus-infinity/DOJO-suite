module.exports = {
  preset: 'ts-jest',
  transform: {
    '^.+\\.[tj]sx?$': 'babel-jest',
  },
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@components/(.*)$': '<rootDir>/src/components/$1', // Added for resolving custom component paths
    '^@hooks/(.*)$': '<rootDir>/src/hooks/$1', // Added for resolving custom hook paths
  },
  setupFilesAfterEnv: ['<rootDir>/config/jest.setup.js'], // Ensure setup file is referenced
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'], // Ensure compatibility with both TypeScript and JavaScript
  coverageDirectory: '<rootDir>/coverage', // Add coverage reporting
  collectCoverageFrom: ['<rootDir>/src/**/*.{ts,tsx,js,jsx}'], // Define which files to include in coverage
};

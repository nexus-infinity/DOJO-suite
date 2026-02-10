#!/bin/bash

echo "Starting the setup and cleanup process..."

# Install necessary dependencies
echo "Installing necessary dependencies..."
npm install --save-dev @babel/preset-env @babel/preset-react @babel/preset-typescript \
                  react-test-renderer @testing-library/jest-dom jest-extended \
                  ts-jest babel-jest 

# Create or update .babelrc file
echo "Creating or updating .babelrc file..."
cat <<EOT > .babelrc
{
  "presets": ["@babel/preset-env", "@babel/preset-react", "@babel/preset-typescript"]
}
EOT

# Create or update jest.config.js file
echo "Creating or updating jest.config.js file..."
cat <<EOT > jest.config.js
export default {
  preset: 'ts-jest',
  extensionsToTreatAsEsm: ['.jsx', '.js', '.ts', '.tsx'],
  transform: {
    '^.+\\.[tj]sx?$': 'babel-jest',
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@modules/(.*)$': '<rootDir>/modules/$1',
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  roots: ['<rootDir>/modules', '<rootDir>/tests'],
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/config/jest.setup.js'],
};
EOT

# Create or update jest.setup.js file (if not exists)
echo "Creating or updating jest.setup.js file..."
cat <<EOT > config/jest.setup.js
import '@testing-library/jest-dom';
import 'jest-extended';

// Add any global mocks here
global.fetch = jest.fn();
EOT

# Cleaning up and installing the latest Babel and React dependencies
echo "Cleaning up module references and paths..."

# Clear node_modules and reinstall dependencies
rm -rf node_modules
npm install

# Clear Jest cache
echo "Clearing Jest cache..."
npx jest --clearCache

# Re-run the Jest tests
echo "Running Jest tests to check if everything is working..."
npx jest

echo "Setup and cleanup process complete!"

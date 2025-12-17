#!/bin/bash

echo "Starting Universal Framework setup with Bear Dancing Protocol..."

# Check if necessary directories exist
directories=("platforms/web/react-app" "modules" "shared")

for dir in "${directories[@]}"; do
    if [ -d "$dir" ]; then
        echo "$dir exists."
    else
        echo "$dir does not exist. Please check your file structure."
    fi
done

# Update .babelrc if necessary
echo "Updating .babelrc if necessary..."
if grep -q '@babel/preset-typescript' .babelrc; then
    echo ".babelrc is already up-to-date."
else
    echo "Updating .babelrc..."
    echo '{
      "presets": ["@babel/preset-env", "@babel/preset-react", "@babel/preset-typescript"]
    }' > .babelrc
    echo ".babelrc updated."
fi

# Update tsconfig.json if necessary
echo "Updating tsconfig.json if necessary..."
if [ -f tsconfig.json ]; then
    echo "tsconfig.json found. Checking..."
    # Modify the tsconfig.json as needed
else
    echo "tsconfig.json not found. Creating a new one..."
    echo '{
      "compilerOptions": {
        "target": "es5",
        "module": "commonjs",
        "strict": true,
        "esModuleInterop": true,
        "skipLibCheck": true,
        "forceConsistentCasingInFileNames": true
      },
      "include": ["src/**/*.ts"],
      "exclude": ["node_modules", "**/*.test.ts"]
    }' > tsconfig.json
fi

# Install npm packages
echo "Installing npm packages..."
npm install

# Check for git conflicts
echo "Checking for git conflicts..."
git diff --check

# Run build process
echo "Running build process..."
npm run build

# Handle build errors and missing files
if [ ! -f dist/index.js ]; then
    echo "Error: dist/index.js not found. Please fix the build errors and re-run the script."
    exit 1
else
    echo "Build completed successfully."
fi

# Additional steps for Bear Dancing Protocol
echo "Bear Dancing Protocol completed successfully."

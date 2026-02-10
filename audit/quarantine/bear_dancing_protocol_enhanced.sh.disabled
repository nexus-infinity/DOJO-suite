#!/bin/bash

# Set root directory
ROOT_DIR="/users/jbear/dev/universal-framework"
REPORT_FILE="$ROOT_DIR/project_management_report.txt"
LOG_FILE="$ROOT_DIR/bear_dancing_protocol.log"

# Function to check and create folders/files if necessary
check_and_fix_structure() {
  local target_path=$1
  local description=$2
  
  echo "Checking $description at $target_path..." | tee -a $LOG_FILE
  
  if [ -d "$target_path" ]; then
    echo "$description exists at $target_path. No action needed." | tee -a $LOG_FILE
    echo "$description: Present" >> $REPORT_FILE
  else
    echo "$description is missing. Logging and creating it now..." | tee -a $LOG_FILE
    mkdir -p "$target_path"
    echo "$description created at $target_path." | tee -a $LOG_FILE
    echo "$description: Created" >> $REPORT_FILE
  fi
}

# Function to verify file contents and make amendments if needed
verify_and_fix_file() {
    local file_path=$1
    local expected_content=$2
    local description=$3
    echo "Checking contents of $description at $file_path..." | tee -a $LOG_FILE
    if [ -f "$file_path" ]; then
        current_content=$(cat "$file_path")
        if [ "$current_content" != "$expected_content" ]; then
            echo "$description at $file_path is not as expected. Amending it now..." | tee -a $LOG_FILE
            echo "$expected_content" > "$file_path"
            echo "$description amended at $file_path." | tee -a $LOG_FILE
            echo "$description: Amended" >> $REPORT_FILE
        else
            echo "$description at $file_path is correct. No action needed." | tee -a $LOG_FILE
            echo "$description: Correct" >> $REPORT_FILE
        fi
    else
        echo "$description is missing. Logging and creating it now..." | tee -a $LOG_FILE
        echo "$expected_content" > "$file_path"
        echo "$description created at $file_path." | tee -a $LOG_FILE
        echo "$description: Created" >> $REPORT_FILE
    fi
}

# Reset or create the report file for each run
echo "Project Management Report - $(date)" > $REPORT_FILE
echo "-----------------------------------" >> $REPORT_FILE

# Example: Check if all key modules and folders exist
MODULES=("shared/adapters" "modules/tata-ai" "modules/nexus" "tests/integration")
for MODULE in "${MODULES[@]}"; do
  check_and_fix_structure "$ROOT_DIR/$MODULE" "$MODULE module"
done

# Example: Check and amend the contents of important files
EXPECTED_BABELRC='{
  "presets": ["@babel/preset-env", "@babel/preset-react", "@babel/preset-typescript"]
}'
verify_and_fix_file "$ROOT_DIR/.babelrc" "$EXPECTED_BABELRC" ".babelrc file"

EXPECTED_JEST_CONFIG="module.exports = {
  preset: 'ts-jest',
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest',
    '^.+\\.(js|jsx)$': 'babel-jest'
  },
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/$1',
    '^@modules/(.*)$': '<rootDir>/modules/$1'
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx'],
  roots: ['<rootDir>/modules', '<rootDir>/tests'],
};"
verify_and_fix_file "$ROOT_DIR/config/jest.config.js" "$EXPECTED_JEST_CONFIG" "Jest config file"

# Completion message
echo "Bear Dancing Protocol completed. Logs available at $LOG_FILE, Report available at $REPORT_FILE."

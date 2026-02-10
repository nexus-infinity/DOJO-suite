#!/bin/bash

# --- Universal Framework Setup and Maintenance Script ---

# Exit immediately if a command exits with a non-zero status
set -e

ROOT_DIR="/users/jbear/dev/universal-framework"
LOG_FILE="$ROOT_DIR/universal_framework_setup.log"
GPT_PROMPT_FILE="$ROOT_DIR/gpt_prompt.txt"

# --- Start Logging ---
echo "Starting Universal Framework Setup and Maintenance..." | tee -a "$LOG_FILE"

# --- Utility functions for logging friendly messages ---
report_success() {
    echo -e "\n[SUCCESS]: $1\n" | tee -a "$LOG_FILE"
}

report_warning() {
    echo -e "\n[WARNING]: $1\n" | tee -a "$LOG_FILE"
}

report_error() {
    echo -e "\n[ERROR]: $1\n" | tee -a "$LOG_FILE"
}

# --- Function to backup existing files before overwriting ---
backup_file() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local backup_path="${file_path}.backup.$(date +%s)"
        cp "$file_path" "$backup_path"
        report_warning "Backed up existing $file_path to $backup_path"
    fi
}

# --- Initialize GPT prompt file ---
echo "Generating GPT prompt recommendations..." > "$GPT_PROMPT_FILE"
echo "Detected issues and potential solutions:" >> "$GPT_PROMPT_FILE"

# --- Function to check and create folders/files only if necessary ---
check_and_fix_structure() {
    local target_path="$1"
    local description="$2"

    if [ -d "$target_path" ]; then
        report_success "$description exists at $target_path. No action needed."
    else
        mkdir -p "$target_path"
        report_warning "$description was missing. Created at $target_path."
        echo "Create or check structure for $description." >> "$GPT_PROMPT_FILE"
    fi
}

# --- Function to verify and fix plain text files ---
verify_and_fix_file() {
    local file_path="$1"
    local expected_content="$2"
    local description="$3"

    if [ -f "$file_path" ]; then
        local current_content
        current_content=$(cat "$file_path")
        if [ "$current_content" != "$expected_content" ]; then
            backup_file "$file_path"
            echo "$expected_content" > "$file_path"
            report_warning "$description was incorrect and has been updated."
            echo "Check if the file $file_path content has been updated correctly." >> "$GPT_PROMPT_FILE"
        else
            report_success "$description is correct. No action needed."
        fi
    else
        echo "$expected_content" > "$file_path"
        report_warning "$description was missing and has been created."
        echo "Verify the file $file_path has the correct content." >> "$GPT_PROMPT_FILE"
    fi
}

# --- Function to verify and fix JSON files using jq ---
verify_and_fix_json_file() {
    local file_path="$1"
    local expected_json="$2"
    local description="$3"

    if [ -f "$file_path" ]; then
        if jq --sort-keys . "$file_path" > /dev/null 2>&1 && \
           [ "$(jq --sort-keys . "$file_path" 2>/dev/null)" = "$(echo "$expected_json" | jq --sort-keys .)" ]; then
            report_success "$description is correct. No action needed."
        else
            backup_file "$file_path"
            echo "$expected_json" | jq . > "$file_path"
            report_warning "$description was incorrect and has been updated."
            echo "Check if the file $file_path content has been updated correctly." >> "$GPT_PROMPT_FILE"
        fi
    else
        echo "$expected_json" | jq . > "$file_path"
        report_warning "$description was missing and has been created."
        echo "Verify the file $file_path has the correct content." >> "$GPT_PROMPT_FILE"
    fi
}

# --- Security and Cleanup ---
echo "Adding .env to .gitignore if not already present..." | tee -a "$LOG_FILE"
GITIGNORE_PATH="$ROOT_DIR/.gitignore"
if grep -qxF '.env' "$GITIGNORE_PATH"; then
    report_success ".env is already present in .gitignore."
else
    echo '.env' >> "$GITIGNORE_PATH"
    report_success ".env successfully added to .gitignore."
fi

# --- Remove unnecessary files (if they exist) ---
echo "Removing unnecessary files and folders..." | tee -a "$LOG_FILE"
UNNECESSARY_FILES=("nexus-infinity" "bear_dancing.sh" "missing_modules.log")
for file in "${UNNECESSARY_FILES[@]}"; do
    FILE_PATH="$ROOT_DIR/$file"
    if [ -e "$FILE_PATH" ]; then
        rm -rf "$FILE_PATH"
        report_success "Removed $file."
    else
        report_success "$file does not exist. No action needed."
    fi
done

# Remove empty directories
find "$ROOT_DIR" -type d -empty -delete
report_success "Unnecessary empty directories removed (if any existed)."

# --- Ensuring config/ directory exists ---
CONFIG_DIR="$ROOT_DIR/config"
check_and_fix_structure "$CONFIG_DIR" "Config directory"

# --- Moving misplaced files (only if they exist) ---
echo "Moving misplaced files..." | tee -a "$LOG_FILE"

MOVE_FILES=("jest.config.js" "jest.setup.js")
for file in "${MOVE_FILES[@]}"; do
    SOURCE_PATH="$ROOT_DIR/$file"
    DEST_PATH="$CONFIG_DIR/$file"
    if [ -f "$SOURCE_PATH" ]; then
        mv "$SOURCE_PATH" "$DEST_PATH"
        report_success "Moved $file to $CONFIG_DIR."
    else
        report_success "$file does not exist in $ROOT_DIR. No action needed."
    fi
done

# --- Installing dependencies if necessary ---
echo "Installing necessary dependencies..." | tee -a "$LOG_FILE"
cd "$ROOT_DIR"

# Define dependencies
DEV_DEPENDENCIES=(
    "@babel/preset-env"
    "@babel/preset-react"
    "@babel/preset-typescript"
    "react-test-renderer"
    "@testing-library/jest-dom"
    "jest-extended"
    "ts-jest"
    "babel-jest"
)

# Install dev dependencies
if npm install --save-dev "${DEV_DEPENDENCIES[@]}" | tee -a "$LOG_FILE"; then
    report_success "Dependencies installed or updated successfully."
else
    report_error "Failed to install dependencies. Please check the logs."
    exit 1
fi

# --- Checking and fixing .babelrc ---
BABELRC_PATH="$ROOT_DIR/.babelrc"
EXPECTED_BABELRC='{
  "presets": ["@babel/preset-env", "@babel/preset-react", "@babel/preset-typescript"]
}'

verify_and_fix_json_file "$BABELRC_PATH" "$EXPECTED_BABELRC" ".babelrc file"

# --- Checking and fixing Jest configuration ---
JEST_CONFIG_PATH="$CONFIG_DIR/jest.config.js"
EXPECTED_JEST_CONFIG="module.exports = {
  preset: 'ts-jest',
  transform: {
    '^.+\\.[tj]sx?$': 'babel-jest',
  },
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/\$1'
  }
};"

verify_and_fix_file "$JEST_CONFIG_PATH" "$EXPECTED_JEST_CONFIG" "Jest config file"

# --- Running Jest tests ---
echo "Running Jest tests..." | tee -a "$LOG_FILE"
if npx jest --clearCache | tee -a "$LOG_FILE" && npx jest --json --outputFile="$ROOT_DIR/test-report.json" | tee -a "$LOG_FILE"; then
    # Check for failed test suites
    if grep -q '"numFailedTestSuites": 0' "$ROOT_DIR/test-report.json"; then
        report_success "All tests passed successfully!"
    else
        report_error "Some test suites failed. Check test-report.json for details."
        echo "Run the following GPT prompt to analyze failed Jest tests: 'Analyze the Jest test failures in the file test-report.json located in the universal-framework project directory and suggest fixes.'" >> "$GPT_PROMPT_FILE"
    fi
else
    report_error "Jest tests failed to run properly. Please check the logs."
    echo "Investigate the Jest setup and configurations." >> "$GPT_PROMPT_FILE"
fi

# --- Final Summary ---
echo -e "\n--- Universal Framework Setup and Maintenance Complete ---\n" | tee -a "$LOG_FILE"

# --- Final GPT prompt recommendations ---
echo -e "\nThe recommended GPT prompt(s) for further analysis have been saved to $GPT_PROMPT_FILE. You can run these prompts to gain insights into any outstanding issues.\n" | tee -a "$LOG_FILE"


#!/bin/bash

# Define the default IDE path
DEFAULT_IDE_PATH=~/.local/share/JetBrains/Toolbox/scripts/phpstorm1

# Get the profile name if provided (first positional argument)
if [[ "$1" != -* && -n "$1" ]]; then
    PROFILE_NAME="$1"
    shift
fi

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--project) PROJECT_PATH="$2"; shift ;;
        -i|--ide-path) IDE_PATH="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Use defaults if not specified
SCRIPT_PATH=$(dirname "${BASH_SOURCE[0]}")
PROJECT_PATH="${PROJECT_PATH:-$SCRIPT_PATH}"
IDE_PATH="${IDE_PATH:-$DEFAULT_IDE_PATH}"

# Check if IDE executable exists
if [ ! -f "$IDE_PATH" ]; then
    echo "IDE executable not found at: $IDE_PATH"
    exit 1
fi

# Get the version output from IDE
version_output=$($IDE_PATH --version)

# Extract the first line using awk
first_line=$(echo "$version_output" | awk 'NR==1')

# Remove space between IDE name and version number, then remove the last .3
processed_version=$(echo "$first_line" | sed 's/ //' | sed 's/\.[0-9]*$//')

# Assign to variable
IDE_VERSION="$processed_version"

IDE_CONFIGURATION_PATH="~/.config/JetBrains/$IDE_VERSION"

# Check if directory exists
if [ ! -d "${IDE_CONFIGURATION_PATH/#\~/$HOME}" ]; then
    echo "Configuration directory does not exist: $IDE_CONFIGURATION_PATH"
    exit 1
fi

# Determine which disabled_plugins file to use
if [ -n "$PROFILE_NAME" ]; then
    DISABLED_PLUGINS_PATH="$SCRIPT_PATH/disabled_plugins/${PROFILE_NAME}_disabled_plugins.txt"
else
    DISABLED_PLUGINS_PATH="$PROJECT_PATH/disabled_plugins.txt"
fi

# Check if disabled_plugins.txt exists in the project directory
if [ ! -f "$DISABLED_PLUGINS_PATH" ]; then
    echo "$DISABLED_PLUGINS_PATH not found in"
    exit 1
fi

# Function to handle file operations
execute_command() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would execute: $*"
    else
        "$@"
    fi
}

# Check if disabled_plugins.txt exists in IDE configuration directory
CONFIG_PLUGINS_FILE="${IDE_CONFIGURATION_PATH/#\~/$HOME}/disabled_plugins.txt"
if [ -f "$CONFIG_PLUGINS_FILE" ]; then
    # Compare files if config file exists
    if ! cmp -s "$DISABLED_PLUGINS_PATH" "$CONFIG_PLUGINS_FILE"; then
        # Files are different - create backup and copy new file
        execute_command mv "$CONFIG_PLUGINS_FILE" "${CONFIG_PLUGINS_FILE}.backup"
        [ "$DRY_RUN" != true ] && echo "Created backup of existing disabled_plugins.txt"
        execute_command cp "$DISABLED_PLUGINS_PATH" "$CONFIG_PLUGINS_FILE"
        [ "$DRY_RUN" != true ] && echo "Copied $DISABLED_PLUGINS_PATH to IDE configuration directory"
    else
        echo "disabled_plugins.txt is already up to date"
    fi
else
    # Config file doesn't exist, copy it
    execute_command cp "$DISABLED_PLUGINS_PATH" "$CONFIG_PLUGINS_FILE"
    [ "$DRY_RUN" != true ] && echo "Copied new $DISABLED_PLUGINS_PATH to IDE configuration directory"
fi

# Run IDE with provided project path
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute: $IDE_PATH $PROJECT_PATH"
else
    "$IDE_PATH" "$PROJECT_PATH"
fi




#!/bin/bash

# Define the default IDE path
DEFAULT_IDE_PATH=~/.local/share/JetBrains/Toolbox/scripts/phpstorm1

execute_command() {
    # For dry run, just show the command to be executed
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would execute: $*"
    # Execute the command
    else
        "$@"
    fi
}

write_plugins_content() {
    # For dry run, show what would be written
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would write the following content to $CONFIG_PLUGINS_FILE:"
        echo "---BEGIN CONTENT---"
        echo "$disabled_plugins_content"
        echo "---END CONTENT---"
    # Write content into file
    else
        echo "$disabled_plugins_content" > "$CONFIG_PLUGINS_FILE"
    fi
}

# Collect all non-flag arguments
PROFILE_NAMES=()
while [[ $# -gt 0 && "$1" != -* ]]; do
    PROFILE_NAMES+=("$1")
    shift
done

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -p|--project) PROJECT_PATH="$2"; shift ;;
        -i|--ide-path) IDE_PATH="$2"; shift ;;
        -D|--dry-run) DRY_RUN=true ;;
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

# Remove space between IDE name and version number, then remove the last version number
processed_version=$(echo "$first_line" | sed 's/ //' | sed 's/\.[0-9]*$//')

IDE_VERSION="$processed_version"

IDE_CONFIGURATION_PATH="~/.config/JetBrains/$IDE_VERSION"

# Check if directory exists
if [ ! -d "${IDE_CONFIGURATION_PATH/#\~/$HOME}" ]; then
    echo "Configuration directory does not exist: $IDE_CONFIGURATION_PATH"
    exit 1
fi

# Define array of enable plugins paths
ENABLE_PLUGINS_PATHS=()
if [ -f "$PROJECT_PATH/enable_plugins.txt" ]; then
    ENABLE_PLUGINS_PATHS+=("$PROJECT_PATH/enable_plugins.txt")
fi

# Initialize empty array for all disabled plugins
disabled_plugins=()

# Determine which disabled_plugins paths to use and load them
if [ ${#PROFILE_NAMES[@]} -gt 0 ]; then
    for profile in "${PROFILE_NAMES[@]}"; do
        profile_path="$SCRIPT_PATH/disabled_plugins/${profile}_disabled_plugins.txt"
        if [ -f "$profile_path" ]; then
            # Append plugins from this profile to the array
            mapfile -t profile_plugins < "$profile_path"
            disabled_plugins+=("${profile_plugins[@]}")
        else
            echo "Warning: disabled plugins file not found for profile '$profile' at: $profile_path"
        fi

        enable_profile_path="$SCRIPT_PATH/disabled_plugins/${profile}_enable_plugins.txt"
        if [ -f "$enable_profile_path" ]; then
            ENABLE_PLUGINS_PATHS+=("$enable_profile_path")
        fi
    done
else
    # Load default disabled plugins
    if [ -f "$PROJECT_PATH/disabled_plugins.txt" ]; then
        mapfile -t disabled_plugins < "$PROJECT_PATH/disabled_plugins.txt"
    fi
fi

# Remove any duplicates
if [ ${#disabled_plugins[@]} -gt 0 ]; then
    disabled_plugins=($(printf '%s\n' "${disabled_plugins[@]}" | awk '!seen[$0]++'))
fi

# Remove plugins from disabled_plugins listed in any enable_plugins.txt files
for enable_plugins_path in "${ENABLE_PLUGINS_PATHS[@]}"; do
    while IFS= read -r enable_plugin; do
        if [ -n "$enable_plugin" ]; then
            # Filter out the enabled plugin from the array
            disabled_plugins=("${disabled_plugins[@]/#$enable_plugin*/}")
        fi
    done < "$enable_plugins_path"
done

# Remove empty elements and create final content
disabled_plugins_content=$(printf '%s\n' "${disabled_plugins[@]}" | grep -v '^$')

# Check if disabled_plugins.txt exists in IDE configuration directory
CONFIG_PLUGINS_FILE="${IDE_CONFIGURATION_PATH/#\~/$HOME}/disabled_plugins.txt"
if [ -f "$CONFIG_PLUGINS_FILE" ]; then
    # Compare contents
    current_content=$(cat "$CONFIG_PLUGINS_FILE")
    if [ "$disabled_plugins_content" != "$current_content" ]; then
        # Content is different - create backup and write new content
        execute_command cp "$CONFIG_PLUGINS_FILE" "${CONFIG_PLUGINS_FILE}.backup"
        [ "$DRY_RUN" != true ] && echo "Created backup of existing disabled_plugins.txt"
        write_plugins_content
        [ "$DRY_RUN" != true ] && echo "Updated disabled plugins in IDE configuration directory"
    else
        echo "disabled_plugins.txt is already up to date"
    fi
else
    # Config file doesn't exist, create it
    write_plugins_content
    [ "$DRY_RUN" != true ] && echo "Created new disabled_plugins.txt in IDE configuration directory"
fi

# Run IDE with provided project path
if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute: $IDE_PATH $PROJECT_PATH"
else
    "$IDE_PATH" "$PROJECT_PATH"
fi

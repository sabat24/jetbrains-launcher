#!/bin/bash

# Path to the launcher script
LAUNCHER_PATH="$HOME/path/to/launcher.sh"

# Get profile name from first argument if provided
PROFILE_NAME="$1"

# Execute launcher with current directory and profile if provided
if [ -n "$PROFILE_NAME" ]; then
    # Shift removes the first argument (profile name) so ${@} contains remaining args
    shift
    "$LAUNCHER_PATH" "$PROFILE_NAME" "-p" "$(pwd)" "$@"
else
    "$LAUNCHER_PATH" "-p" "$(pwd)" "$@"
fi 

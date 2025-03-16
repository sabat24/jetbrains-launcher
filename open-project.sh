#!/bin/bash

# Path to the launcher script
LAUNCHER_PATH="$HOME/path/to/launcher.sh"

# Collect all non-flagged arguments as profile name
PROFILE_NAME=""
REMAINING_ARGS=()

for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
        REMAINING_ARGS+=("$arg")
    else
        if [ -z "$PROFILE_NAME" ]; then
            PROFILE_NAME="$arg"
        else
            PROFILE_NAME="$PROFILE_NAME $arg"
        fi
    fi
done

# Execute launcher with current directory and profile if provided
if [ -n "$PROFILE_NAME" ]; then
    "$LAUNCHER_PATH" $PROFILE_NAME "-p" "$(pwd)" "${REMAINING_ARGS[@]}"
else
    "$LAUNCHER_PATH" "-p" "$(pwd)" "${REMAINING_ARGS[@]}"
fi 

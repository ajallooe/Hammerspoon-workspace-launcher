#!/bin/sh

HAMMER_DIR="$HOME/.hammerspoon"
REPO_DIR="$HAMMER_DIR/hammerspoon-workspace-launcher"
INIT_FILE="$HAMMER_DIR/init.lua"
WORKSPACES_DIR="$HAMMER_DIR/workspaces"
REQUIRE_LINE='require("hammerspoon-workspace-launcher.hotkey")'

# Ensure workspace directory exists
mkdir -p "$WORKSPACES_DIR"

# Create init.lua if it doesn't exist
if [ ! -f "$INIT_FILE" ]; then
  echo "-- Hammerspoon init.lua created by install script" > "$INIT_FILE"
fi

# Check if the require line is already present
if grep -qF "$REQUIRE_LINE" "$INIT_FILE"; then
  echo "hotkey.lua already sourced in init.lua"
else
  echo "$REQUIRE_LINE" >> "$INIT_FILE"
  echo "Appended $REQUIRE_LINE to $INIT_FILE"
fi
#!/bin/sh

# Hammerspoon Workspace Launcher - Installation Script
#
# This script sets up the launcher by:
#   - Creating necessary directories
#   - Appending a require line to Hammerspoon's init.lua (if not already present)
#   - Exporting PATH to a sourced shell file so Hammerspoon sees full environment

# -------------------------------------------------------------------
# Setup paths
# -------------------------------------------------------------------

HAMMER_DIR="$HOME/.hammerspoon"
REPO_DIR="$HAMMER_DIR/hammerspoon-workspace-launcher"
INIT_FILE="$HAMMER_DIR/init.lua"
WORKSPACES_DIR="$HAMMER_DIR/workspaces"
SHELL_ENV="$HAMMER_DIR/hammerspoon_env.sh"
REQUIRE_LINE='require("hammerspoon-workspace-launcher.main")'

# -------------------------------------------------------------------
# Export PATH to ensure Hammerspoon inherits full shell environment
# -------------------------------------------------------------------

echo "export PATH=\"$PATH\"" > "$SHELL_ENV"

# -------------------------------------------------------------------
# Ensure required directories exist
# -------------------------------------------------------------------

mkdir -p "$WORKSPACES_DIR"

# -------------------------------------------------------------------
# Create init.lua if it doesn't exist
# -------------------------------------------------------------------

if [ ! -f "$INIT_FILE" ]; then
    echo "-- Hammerspoon init.lua created by install script" > "$INIT_FILE"
fi

# -------------------------------------------------------------------
# Append require line if not already present
# -------------------------------------------------------------------

if grep -qF "$REQUIRE_LINE" "$INIT_FILE"; then
    echo "hotkey.lua already sourced in init.lua"
else
    echo "$REQUIRE_LINE" >> "$INIT_FILE"
    echo "Appended $REQUIRE_LINE to $INIT_FILE"
fi
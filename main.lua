-- Hammerspoon Main Configuration Script
--
-- This script initializes the workspace command system and visual window border overlay.
--
-- Features:
--   - Default hotkey (Cmd+Alt+Ctrl+`) to launch the workspace command prompt (configurable in config.lua)
--   - Default hotkey (Cmd+Alt+Ctrl+-) to toggle the window border overlay on/off (configurable in config.lua)
--   - Draws a highlight border around the currently focused window
--
-- Dependencies:
--   - config.lua for user-configurable settings
--   - commands.lua for command parsing and execution
--   - border.lua for drawing and managing the visual border

local config   = require("hammerspoon-workspace-launcher.config")
local hotkeys  = config.hotkeys

-- Load and bind workspace command prompt
local commands = require("hammerspoon-workspace-launcher.commands")

hs.hotkey.bind(hotkeys.commandPrompt.modifiers, hotkeys.commandPrompt.key, function()
    commands.showCommandPrompt()
end)

-- Load and initialize border drawing logic
local border = require("hammerspoon-workspace-launcher.border")

border.init()

local borderEnabled = true

-- Hotkey to toggle the border overlay on/off
hs.hotkey.bind(hotkeys.toggleBorder.modifiers, hotkeys.toggleBorder.key, function()
    borderEnabled = not borderEnabled
    if borderEnabled then
        hs.alert("Border ON")
        border.init()
    else
        hs.alert("Border OFF")
        border.stop()
    end
end)
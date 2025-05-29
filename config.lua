-- Global Configuration for Hammerspoon Workspace Launcher
--
-- Configuration table returned to other modules.
-- Modify these values to change the appearance and behavior of features.
--
-- Additional configuration sections can go here, e.g., layout, workspace behavior, etc.

-- ========================== CONFIGURATION ==========================

return {
    -- Default hotkeys for core features
    -- Modify these values to customize keybindings throughout the system
    hotkeys = {
        commandPrompt = { modifiers = { "cmd", "alt", "ctrl" }, key = "`" },
        toggleBorder  = { modifiers = { "cmd", "alt", "ctrl" }, key = "-" },
    },

    -- Settings for the active window border overlay
    -- These control how the border looks and behaves during focus and resize events
    border = {
        borderWidth    = 10,   -- Thickness of the border line in pixels
        cornerRadius   = 10,   -- Radius in pixels for rounded corners
        borderColor    = { red = 1.0, green = 0.8, blue = 0.1, alpha = 0.8 }, -- Normal border RGBA color
        flashColor     = { red = 1.0, green = 0.0, blue = 0.0, alpha = 1.0 }, -- Flash effect RGBA color
        flashDuration  = 0.15, -- Duration of the flash in seconds
    },
}

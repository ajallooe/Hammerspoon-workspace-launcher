-- Workspace Launcher Module
-- 
-- Launches a predefined set of applications, browser tabs, and tools for a given workspace name.
-- It loads configuration files from ~/.hammerspoon/workspaces/<name>.apps.lua
-- Each configuration may define multiple app categories:
--   - chrome / edge / safari: Open a browser with specified URLs and profiles
--   - code: Launch Visual Studio Code with a profile and workspace
--   - finder: Open Finder windows for specific file paths
--   - iterm: Launch iTerm2 with tabs and commands
--   - obsidian: Open Obsidian with a vault and file
--   - generic: Launch any other macOS apps by name
-- 
-- This module is used by commands.lua to trigger a workspace launch by name.
-- The workspace launcher is invoked through a configurable hotkey defined in config.lua (`hotkeys.launchWorkspace`).

local function escape_osascript_string(s)
    return s:gsub('\\', '\\\\'):gsub('"', '\\"')
end


local M = {}

local workspaceDir = os.getenv("HOME") .. "/.hammerspoon/workspaces"
local defaultFile = os.getenv("HOME") .. "/.hammerspoon/browser_fallback.html"


-- Main function to launch a workspace setup by name
-- Loads the corresponding config file and dispatches actions for each app/tool type
function M.launch(project)
    local ok, config = pcall(dofile, workspaceDir .. "/" .. project .. ".apps.lua")
    if not ok then
        hs.alert.show("Couldn't load: " .. project)
        return
    end


    -- fallback URL for tab group hint
    local function localTabGroupPage(title)
        local file = io.open(defaultFile, "w")
        file:write(string.format([[<html><body>
        <h2>Restore Tab Group</h2>
        <p>This workspace (%s) does not define any URLs.</p>
        <p>Please manually restore the tab group in your browser.</p>
        </body></html>]], title))
        file:close()
        return "file://" .. defaultFile
    end


    -- Launch Chrome browser with profile and URLs (if any)
    if config.chrome then
        local chrome = config.chrome
        local urls = chrome.urls or {}
        local launchUrls = #urls > 0 and ('"' .. table.concat(urls, '" "') .. '"') or localTabGroupPage(config.title or project)
        hs.execute(string.format('open -na "Google Chrome" --args --new-window --profile-directory="%s" %s',
            chrome.profile, launchUrls))
    end


    -- Launch Microsoft Edge with profile and URLs (if any)
    if config.edge then
        local edge = config.edge
        local urls = edge.urls or {}
        local launchUrls = #urls > 0 and ('"' .. table.concat(urls, '" "') .. '"') or localTabGroupPage(config.title or project)
        hs.execute(string.format('open -na "Microsoft Edge" --args --new-window --profile-directory="%s" %s',
            edge.profile, launchUrls))
        hs.execute('open -a "Microsoft Edge"')
    end


    -- Launch Safari with specified URLs or fallback page
    if config.safari then
        local urls = config.safari.urls or {}
        if #urls > 0 then
            local script = string.format([[
tell application "Safari"
    set W to make new document with properties {URL:"%s"}
    delay 0.3
    tell W
]], urls[1])
            for i = 2, #urls do
                script = script .. string.format('\n        make new tab with properties {URL:"%s"}', urls[i])
            end
            script = script .. [[
    end tell
    activate
end tell
]]
            hs.osascript.applescript(script)
        else
            hs.execute(string.format('open -a Safari "%s"', localTabGroupPage(config.title or project)))
        end
    end


    -- Launch Visual Studio Code with profile and workspace
    if config.code then
        local vscodeBin = hs.execute(". ~/.hammerspoon/hammerspoon_env.sh; which code"):gsub("%s+$", "")
        if vscodeBin and vscodeBin ~= "" then
            hs.execute(string.format('. ~/.hammerspoon/hammerspoon_env.sh; %s --profile "%s" "%s"', vscodeBin, config.code.profile, config.code.workspace))
        else
            hs.alert.show("VSCode CLI 'code' not found in PATH")
        end
    end


    -- Open Finder windows to listed directories
    if config.finder then
        local locs = config.finder.locations or {}
        if #locs > 0 then
            local script = string.format('tell application "Finder"\n    activate\n    make new Finder window to (POSIX file "%s")\nend tell\n', locs[1])
            for i = 2, #locs do
                script = script .. string.format([[
tell application "System Events"
    tell process "Finder"
        delay 0.3
        keystroke "t" using {command down}
        delay 0.2
        keystroke "g" using {shift down, command down}
        delay 0.2
        keystroke "%s" & return
    end tell
end tell
]], locs[i])
            end
            hs.osascript.applescript(script)
        end
    end


    -- Launch iTerm2 and run specified commands in tabs
    if config.iterm then
        local script = [[
tell application "iTerm2"
    create window with default profile
]]
        for i, tab in ipairs(config.iterm.tabs or {}) do
            if i == 1 then
                script = script .. string.format('\ntell current session of current window\n    write text "%s"\nend tell', escape_osascript_string(tab.command))
            else
                script = script .. string.format([[
    tell current window
        create tab with profile "%s"
        tell current session
            write text "%s"
        end tell
    end tell]], tab.profile, escape_osascript_string(tab.command))
            end
        end
        hs.osascript.applescript(script .. "\nend tell")
    end


    -- Open Obsidian vault and file
    if config.obsidian then
        local url = string.format("obsidian://open?vault=%s", config.obsidian.vault)
        if config.obsidian.file then
            url = url .. "&file=" .. config.obsidian.file
        end
        hs.execute('open "' .. url .. '"')
    end


    -- Launch any additional generic macOS apps by name
    if config.generic and config.generic.apps then
        for _, app in ipairs(config.generic.apps) do
            if app.name then
                hs.application.launchOrFocus(app.name)
            end
        end
    end
end


return M
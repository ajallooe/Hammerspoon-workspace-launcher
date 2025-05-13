local M = {}

local workspaceDir = os.getenv("HOME") .. "/.hammerspoon/workspaces"
local defaultFile = os.getenv("HOME") .. "/.hammerspoon/browser_fallback.html"

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

    -- Chrome
    if config.chrome then
        local chrome = config.chrome
        local urls = chrome.urls or {}
        local launchUrls = #urls > 0 and ('"' .. table.concat(urls, '" "') .. '"') or localTabGroupPage(config.title or project)
        hs.execute(string.format('open -na "Google Chrome" --args --profile-directory="%s" %s',
            chrome.profile, launchUrls))
    end

    -- Safari
    if config.safari then
        local urls = config.safari.urls or {}
        if #urls > 0 then
            local script = string.format([[
                tell application "Safari"
                    activate
                    make new document
                    set URL of front document to "%s"
                    tell front window
            ]], urls[1])
            for i = 2, #urls do
                script = script .. string.format('\nmake new tab with properties {URL:"%s"}', urls[i])
            end
            script = script .. [[
                    end tell
                end tell
            ]]
            hs.osascript.applescript(script)
        else
            hs.execute(string.format('open -a Safari "%s"', localTabGroupPage(config.title or project)))
        end
    end

    -- VSCode
    if config.code then
        hs.execute(string.format('code "%s" --profile "%s"',
            config.code.workspace, config.code.profile))
    end

    -- Finder
    if config.finder then
        local locs = config.finder.locations or {}
        if #locs > 0 then
            local script = string.format('tell application "Finder"\nactivate\nmake new Finder window to (POSIX file "%s")\nend tell\n', locs[1])
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

    -- iTerm
    if config.iterm then
        local script = [[tell application "iTerm2" to create window with default profile]]
        for i, tab in ipairs(config.iterm.tabs or {}) do
            if i == 1 then
                script = script .. string.format('\ntell current session of current window\nwrite text "%s"\nend tell', tab.command)
            else
                script = script .. string.format([[
                    tell current window
                        create tab with profile "%s"
                        tell current session
                            write text "%s"
                        end tell
                    end tell]], tab.profile, tab.command)
            end
        end
        hs.osascript.applescript(script .. "\nend tell")
    end

    -- Obsidian
    if config.obsidian then
        local url = string.format("obsidian://open?vault=%s", config.obsidian.vault)
        if config.obsidian.file then
            url = url .. "&file=" .. config.obsidian.file
        end
        hs.execute('open "' .. url .. '"')
    end

    -- Generic macOS apps
    if config.generic and config.generic.apps then
        for _, app in ipairs(config.generic.apps) do
            if app.name then
                hs.application.launchOrFocus(app.name)
            end
        end
    end
end

return M
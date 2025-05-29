-- Workspace Commands Module
--
-- Provides a unified command prompt interface for launching and managing workspace environments.
-- Available commands include:
--     - Save and restore window layouts
--     - Launch project apps only
--     - Launch full project (apps and layout)
--     - Dump window info
--     - Open workspace folder in Terminal
--
-- Displays a floating help overlay and a text input prompt to enter a command.
-- The command prompt is triggered via a default hotkey defined in config.lua.
-- Executes corresponding actions using layout functions or the launcher module.

local launcher = require("hammerspoon-workspace-launcher.launcher")
local M = {}

local workspaceDir = os.getenv("HOME") .. "/.hammerspoon/workspaces"
hs.fs.mkdir(workspaceDir)

local function layoutPath(name)
    return workspaceDir .. "/" .. name .. ".placement.lua"
end

local function appsPath(name)
    return workspaceDir .. "/" .. name .. ".apps.lua"
end

local function saveCurrentLayout(name)
    local layout = {}
    for _, win in ipairs(hs.window.allWindows()) do
        local app   = win:application():name()
        local title = win:title()
        local frame = win:frame()
        table.insert(layout, { app = app, title = title, x = frame.x, y = frame.y, w = frame.w, h = frame.h })
    end

    local f = io.open(layoutPath(name), "w")
    f:write("return " .. hs.inspect(layout))
    f:close()
    hs.alert.show("Layout saved: " .. name)
end

local function restoreLayout(name)
    local ok, layout = pcall(dofile, layoutPath(name))
    if not ok or not layout then
        hs.alert.show("Could not load layout: " .. name)
        return
    end

    for _, savedWin in ipairs(layout) do
        for _, win in ipairs(hs.window.allWindows()) do
            local app, title = win:application():name(), win:title()
            if app == savedWin.app and title:lower():find(savedWin.title:lower(), 1, true) then
                win:setFrame({ x = savedWin.x, y = savedWin.y, w = savedWin.w, h = savedWin.h })
                break
            end
        end
    end

    hs.alert.show("Layout restored: " .. name)
end

-- Shows the command prompt and dispatches user-entered commands
M.showCommandPrompt = function()
    local helpText = table.concat({
        " s <name>     Save layout under given name",
        " r <name>     Restore layout by name",
        " l <name>     Launch apps only for project",
        " p <name>     Launch project (apps + layout)",
        " d            Dump current window info to console",
        " e            Open workspace folder in Terminal",
    }, "\n")

    local screenFrame = hs.screen.mainScreen():frame()
    local textWidth, textHeight = 520, 180
    local x = screenFrame.x + (screenFrame.w - textWidth) / 2
    -- local y = screenFrame.y + (screenFrame.h - textHeight) / 18
    local y = 30

    local helpBg = hs.drawing.rectangle({ x = x, y = y, w = textWidth, h = textHeight })
    helpBg:setFillColor({ white = 0, alpha = 0.9 })
    helpBg:setFill(true)
    helpBg:setStroke(false)

    local helpTextObj = hs.drawing.text({ x = x + 20, y = y + 20, w = textWidth - 40, h = textHeight - 40 }, helpText)
    helpTextObj:setTextFont("Menlo")
    helpTextObj:setTextSize(14)
    helpTextObj:setTextColor({ white = 1 })
    helpTextObj:setBehaviorByLabels({ "canJoinAllSpaces", "stationary" })
    helpTextObj:bringToFront(true)

    helpBg:show()
    helpTextObj:show()

    local button, input = hs.dialog.textPrompt(
        "Workspace Control",
        "",
        "",
        "Run",
        "Cancel"
    )

    helpBg:delete()
    helpTextObj:delete()

    if button ~= "Run" or not input or input == "" then
        return
    end

    local cmd, arg = input:match("^(%S+)%s*(.*)$")

    -- Dump current window information to the console
    if cmd == "d" then
        for _, win in ipairs(hs.window.allWindows()) do
            local app, title = win:application():name(), win:title()
            local f = win:frame()
            print(string.format(
                '[%s] "%s"\n  Position: {x = %d, y = %d}, Size: {w = %d, h = %d}',
                app, title, f.x, f.y, f.w, f.h
            ))
        end
        hs.alert.show("Window info dumped")

    -- Save the current layout to a named file
    elseif cmd == "s" and arg ~= "" then
        saveCurrentLayout(arg)

    -- Restore layout from a named file
    elseif cmd == "r" and arg ~= "" then
        restoreLayout(arg)

    -- Launch apps defined for a project
    elseif cmd == "l" and arg ~= "" then
        launcher.launch(arg)

    -- Launch apps and then restore layout for a project
    elseif cmd == "p" and arg ~= "" then
        launcher.launch(arg)
        hs.timer.doAfter(6, function() restoreLayout(arg) end)

    -- Open the workspace folder in Terminal
    elseif cmd == "e" then
        hs.execute("open -a Terminal \"" .. workspaceDir .. "\"")
        hs.alert.show("Opened workspace folder in Terminal")

    -- Handle unknown or invalid commands
    else
        hs.alert.show("Unknown command")
    end
end

return M
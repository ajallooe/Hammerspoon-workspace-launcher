local launcher = require("hammerspoon-workspace-launcher.launcher")
local M = {}

local workspaceDir = os.getenv("HOME") .. "/.hammerspoon/workspaces"
hs.fs.mkdir(workspaceDir)

local function layoutPath(name) return workspaceDir .. "/" .. name .. ".placement.lua" end
local function appsPath(name) return workspaceDir .. "/" .. name .. ".apps.lua" end

local function saveCurrentLayout(name)
    local layout = {}
    for _, win in ipairs(hs.window.allWindows()) do
        local app = win:application():name()
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

M.showCommandPrompt = function()
    local chooser = hs.chooser.new(function(choice)
        if not choice then return end
        local input = choice.subText or ""
        local cmd, arg = input:match("^(%S+)%s*(.*)$")

        if cmd == "d" then
            for _, win in ipairs(hs.window.allWindows()) do
                local app, title = win:application():name(), win:title()
                local f = win:frame()
                print(string.format('[%s] "%s"\n  Position: {x = %d, y = %d}, Size: {w = %d, h = %d}', app, title, f.x, f.y, f.w, f.h))
            end
            hs.alert.show("Window info dumped")

        elseif cmd == "s" and arg ~= "" then
            saveCurrentLayout(arg)

        elseif cmd == "r" and arg ~= "" then
            restoreLayout(arg)

        elseif cmd == "l" and arg ~= "" then
            launcher.launch(arg)

        elseif cmd == "p" and arg ~= "" then
            launcher.launch(arg)
            hs.timer.doAfter(6, function() restoreLayout(arg) end)

        elseif cmd == "e" then
            hs.execute("open -a Terminal \"" .. workspaceDir .. "\"")
            hs.alert.show("Opened workspace folder in Terminal")

        else
            hs.alert.show("Unknown command")
        end
    end)

    chooser:choices({
        { text = "Dump window positions", subText = "d" },
        { text = "Save current layout", subText = "s <workspace>" },
        { text = "Restore layout", subText = "r <workspace>" },
        { text = "Launch apps only", subText = "l <workspace>" },
        { text = "Launch apps and layout", subText = "p <workspace>" },
        { text = "Open workspace folder", subText = "e" }
    })
    chooser:placeholderText("Type a command like: s <workspace> or p <workspace>")
    chooser:width(50)
    chooser:show()
end

return M
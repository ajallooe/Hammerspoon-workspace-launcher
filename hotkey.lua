local commands = require("hammerspoon-workspace-launcher.commands")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "`", function()
    commands.showCommandPrompt()
end)
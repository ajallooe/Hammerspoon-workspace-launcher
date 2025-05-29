-- Hammerspoon module to draw a visual border around the currently focused window.
--
-- This visual effect helps users identify the active window by highlighting it with a rounded rectangle.
-- The border can briefly flash when the focus changes or when window movement/resizing occurs.
-- 
-- Appearance and behavior are fully configurable via `config.lua` under the `border` key:
--   - config.border.borderWidth     - thickness of the border line
--   - config.border.cornerRadius    - corner rounding of the rectangle
--   - config.border.borderColor     - normal border color
--   - config.border.flashColor      - color used for flash effect
--   - config.border.flashDuration   - flash duration in seconds
--
-- The default hotkey to toggle this feature on/off is also defined in `config.lua` under `hotkeys.toggleBorder`.

local M      = {}
local config = require("hammerspoon-workspace-launcher.config").border

local border = nil

-- Watch mouse drag and release events to temporarily disable border
-- Used to hide the border during window resizing/movement for smoother visual behavior
local dragWatcher = hs.eventtap.new(
  { hs.eventtap.event.types.leftMouseDragged, hs.eventtap.event.types.leftMouseUp },
  function(event)
    local eventType = event:getType()

    if eventType == hs.eventtap.event.types.leftMouseDragged then
      if border then
        border:setStrokeColor(config.flashColor)
        hs.timer.doAfter(config.flashDuration or 0.15, function()
          if border then
            border:delete()
            border = nil
          end
        end)
      end
    elseif eventType == hs.eventtap.event.types.leftMouseUp then
      hs.timer.doAfter(0.1, function() M.draw() end)
    end

    return false
  end
)

-- Draws a border around the currently focused window
function M.draw()
  if border then border:delete() end

  local win = hs.window.focusedWindow()
  if not win or not win:isStandard() then
    border = nil
    return
  end

  local frame = win:frame()
  border = hs.drawing.rectangle(frame)
  border:setRoundedRectRadii(config.cornerRadius, config.cornerRadius)
  border:setStrokeColor(config.borderColor)
  border:setFill(false)
  border:setStrokeWidth(config.borderWidth)
  border:bringToFront(true)
  border:setLevel(hs.drawing.windowLevels.overlay)

  border:setStrokeColor(config.flashColor)
  border:show()
  hs.timer.doAfter(config.flashDuration or 0.15, function()
    if border then border:setStrokeColor(config.borderColor) end
  end)
end

-- Initializes event subscriptions and the drag watcher
function M.init()
  local filter = hs.window.filter.default

  filter:subscribe(hs.window.filter.windowFocused, function()
    M.draw()
  end)

  filter:subscribe(hs.window.filter.windowUnfocused, function()
    if border then
      border:delete()
      border = nil
    end
  end)

  filter:subscribe("windowMoved", function()
    M.draw()
  end)

  dragWatcher:start()
end

-- Removes any active border and stops all watchers
function M.stop()
  if border then
    border:delete()
    border = nil
  end

  hs.window.filter.default:unsubscribe(hs.window.filter.windowFocused)
  dragWatcher:stop()
end

return M
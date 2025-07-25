---@diagnostic disable: undefined-global

-- instant movement for built-in window management
hs.window.animationDuration = 0

hs.loadSpoon("Hammerflow")
spoon.Hammerflow.loadFirstValidTomlFile({
    "Spoons/Hammerflow.spoon/default.toml",
})
if spoon.Hammerflow.auto_reload then
    hs.loadSpoon("ReloadConfiguration")
    spoon.ReloadConfiguration:start()
end

hs.loadSpoon("ClipboardTool")
spoon.ClipboardTool.paste_on_select = true
spoon.ClipboardTool.show_in_menubar = false
spoon.ClipboardTool:start()
hs.hotkey.bind({"alt"}, "v", function()
  spoon.ClipboardTool:toggleClipboard()
end)


hs.hotkey.bind({"ctrl", "alt", "shift", "cmd"}, "k", function()
    hs.application.launchOrFocus("Kitty")
end)

require('applauncher')     --see applauncher.lua
require('appmenu2')        --see appmenu2.lua 
require('switcher')        --see switcher.lua
require('aerospace')       --see aerospace.lua

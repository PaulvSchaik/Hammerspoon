-- hs.chooser applicatie launcher in aangepaste stijl

local chooser = nil

local style = {
    font = { name = "MesloLGS NF", size = 14 },
    color = { red = 0.471, green = 0.663, blue = 1, alpha = 1 }
}

-- Ophalen van alle apps in /Applications en ~/Applications, met iconen
function getInstalledApps()
    local items = {}
    local paths = { "/Applications", os.getenv("HOME") .. "/Applications" }

    for _, dir in ipairs(paths) do
        local handle = io.popen('ls -1 "' .. dir .. '" | grep ".app$"')
        if handle then
            for app in handle:lines() do
                local appName = app:gsub("%.app$", "")
                local fullPath = dir .. "/" .. app
                local icon = hs.image.iconForFile(fullPath)

                table.insert(items, {
                    text = hs.styledtext.new(appName, {
                        font = style.font,
                        color = style.color
                    }),
                    image = icon,
                    path = fullPath
                })
            end
            handle:close()
        end
    end

    table.sort(items, function(a, b)
        return tostring(a.text) < tostring(b.text)
    end)

    return items
end

function showAppLauncher()
    local items = getInstalledApps()
    if #items == 0 then
        hs.alert("Geen applicaties gevonden")
        return
    end

    chooser = hs.chooser.new(function(choice)
        if not choice then return end
        hs.application.launchOrFocus(choice.path)
    end)

    chooser:choices(items)
    chooser:placeholderText("Zoek app…")
    chooser:searchSubText(false)
    chooser:show()
end

-- Cmd + D
hs.hotkey.bind({"cmd"}, "D", function()
    hs.timer.doAfter(0.1, function()
        showAppLauncher()
    end)
end)

-- URL-handler
hs.urlevent.bind("showAppLauncher", function()
    hs.timer.doAfter(0.1, function()
        showAppLauncher()
    end)
end)


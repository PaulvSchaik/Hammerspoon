-- hs.chooser application starter

local chooser = nil
local menuElementMap = {}

local style = {
    font = { name = "MesloLGS NF", size = 14 },
    color = { red = 0.471, green = 0.663, blue = 1, alpha = 1 }
}

local function uuid() return hs.host.uuid() end

function scanMenuTree(axElement, path)
    local results = {}
    local children = axElement:attributeValue("AXChildren")
    if not children then return results end

    for _, child in ipairs(children) do
        local title = child:attributeValue("AXTitle")
        local role = child:attributeValue("AXRole")
        local enabled = child:attributeValue("AXEnabled")

        if role == "AXMenuItem" and enabled then
            local fullPath = path .. (title and (" → " .. title) or "")
            local id = uuid()
            menuElementMap[id] = child

            local styledTitle = hs.styledtext.new(fullPath, {
                font = style.font,
                color = style.color
            })

            table.insert(results, { text = styledTitle, uuid = id })

            local hasSubmenu = child:attributeValue("AXChildren")
            if hasSubmenu then
                local subitems = scanMenuTree(child, fullPath)
                for _, si in ipairs(subitems) do
                    table.insert(results, si)
                end
            end
        end
    end
    return results
end

function getAllMenuItems()
    local app = hs.application.frontmostApplication()
    if not app then return {} end
    local axApp = hs.axuielement.applicationElement(app)
    local menuBar = axApp:attributeValue("AXMenuBar")
    if not menuBar then
        hs.alert("Geen toegang tot menubalk — controleer Toegankelijkheid")
        return {}
    end

    menuElementMap = {}
    local allItems = {}

    for _, menu in ipairs(menuBar:attributeValue("AXChildren")) do
        local topTitle = menu:attributeValue("AXTitle") or "?"
        local children = menu:attributeValue("AXChildren")
        if children then
            for _, child in ipairs(children) do
                if child:attributeValue("AXRole") == "AXMenu" then
                    local items = scanMenuTree(child, topTitle)
                    for _, i in ipairs(items) do
                        table.insert(allItems, i)
                    end
                end
            end
        end
    end
    return allItems
end

function showMenuChooser()
    local items = getAllMenuItems()
    if #items == 0 then
        hs.alert("Geen menu-items gevonden")
        return
    end

    chooser = hs.chooser.new(function(choice)
        if not choice then return end
        local menuElement = menuElementMap[choice.uuid]
        if menuElement then
            menuElement:performAction("AXPress")
        else
            hs.alert("Kan menu-element niet uitvoeren")
        end
    end)

    chooser:choices(items)
    chooser:placeholderText("Zoek menu-item…")
    chooser:searchSubText(false)
    chooser:show()
end

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "tab", function()
    hs.timer.doAfter(0.1, function()
        showMenuChooser()
    end)
end)

-- URL handler 
hs.urlevent.bind("showAppMenu", function()
    hs.timer.doAfter(0.1, function()
        showMenuChooser()
    end)
end)

